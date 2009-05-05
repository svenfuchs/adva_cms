require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/models')

describe IsParanoid do
  before(:each) do
    Android.delete_all
    Person.delete_all
    Component.delete_all

    @luke = Person.create(:name => 'Luke Skywalker')
    @r2d2 = Android.create(:name => 'R2D2', :owner_id => @luke.id)
    @c3p0 = Android.create(:name => 'C3P0', :owner_id => @luke.id)
    @r2d2.components.create(:name => 'Rotors')
  end

  describe 'destroying' do
    it "should soft-delete a record" do
       lambda{
         Android.destroy(@r2d2.id)
       }.should change(Android, :count).from(2).to(1)
       Android.count_with_destroyed.should == 2
    end

    it "should not hit update/save related callbacks" do
      lambda{
        Android.first.update_attribute(:name, 'Robocop')
      }.should raise_error

      lambda{
        Android.first.destroy
      }.should_not raise_error
    end

    it "should soft-delete matching items on Model.destroy_all" do
      lambda{
        Android.destroy_all("owner_id = #{@luke.id}")
      }.should change(Android, :count).from(2).to(0)
      Android.count_with_destroyed.should == 2
    end

    describe 'related models' do
      it "should no longer show up in the relationship to the owner" do
        @luke.androids.size.should == 2
        @r2d2.destroy
        @luke.androids.size.should == 1
      end

      it "should soft-delete on dependent destroys" do
        lambda{
          @luke.destroy
        }.should change(Android, :count).from(2).to(0)
        Android.count_with_destroyed.should == 2
      end

    end
  end

  describe 'finding destroyed models' do
    it "should be able to find destroyed items via #find_with_destroyed" do
      @r2d2.destroy
      Android.find(:first, :conditions => {:name => 'R2D2'}).should be_blank
      Android.first_with_destroyed(:conditions => {:name => 'R2D2'}).should_not be_blank
    end

    it "should be able to find only destroyed items via #find_destroyed_only" do
      @r2d2.destroy
      Android.all_destroyed_only.size.should == 1
      Android.first_destroyed_only.should == @r2d2
    end
  end

  describe 'calculations' do
    it "should have a proper count inclusively and exclusively of destroyed items" do
      @r2d2.destroy
      @c3p0.destroy
      Android.count.should == 0
      Android.count_with_destroyed.should == 2
    end

    it "should respond to various calculations" do
      @r2d2.destroy
      Android.sum('id').should == @c3p0.id
      Android.sum_with_destroyed('id').should == @r2d2.id + @c3p0.id
      Android.average_with_destroyed('id').should == (@r2d2.id + @c3p0.id) / 2.0
    end
  end

  describe 'deletion' do
    it "should actually remove records on #delete_all" do
      lambda{
        Android.delete_all
      }.should change(Android, :count_with_destroyed).from(2).to(0)
    end

    it "should actually remove records on #delete" do
      lambda{
        Android.first.delete
      }.should change(Android, :count_with_destroyed).from(2).to(1)
    end
  end

  describe 'restore' do
    it "should allow restoring soft-deleted items" do
      @r2d2.destroy
      lambda{
        @r2d2.restore
      }.should change(Android, :count).from(1).to(2)
    end

    it "should not hit update/save related callbacks" do
      @r2d2.destroy

      lambda{
        @r2d2.update_attribute(:name, 'Robocop')
      }.should raise_error

      lambda{
        @r2d2.restore
      }.should_not raise_error
    end

    it "should restore dependent models when being restored by default" do
      @r2d2.destroy
      lambda{
        @r2d2.restore
      }.should change(Component, :count).from(0).to(1)
    end

    it "should provide the option to not restore dependent models" do
      @r2d2.destroy
      lambda{
        @r2d2.restore(:include_destroyed_dependents => false)
      }.should_not change(Component, :count)
    end
  end

  describe 'validations' do
    it "should not ignore destroyed items in validation checks unless scoped" do
      # Androids are not validates_uniqueness_of scoped
      @r2d2.destroy
      lambda{
        Android.create!(:name => 'R2D2')
      }.should raise_error(ActiveRecord::RecordInvalid)

      lambda{
        # creating shouldn't raise an error
        another_r2d2 = AndroidWithScopedUniqueness.create!(:name => 'R2D2')
        # neither should destroying the second incarnation since the
        # validates_uniqueness_of is only applied on create
        another_r2d2.destroy
      }.should_not raise_error
    end
  end

  describe 'alternate fields and field values' do
    it "should properly function for boolean values" do
      # ninjas are invisible by default.  not being ninjas, we can only
      # find those that are visible
      ninja = Ninja.create(:name => 'Esteban', :visible => true)
      ninja.vanish # aliased to destroy
      Ninja.first.should be_blank
      Ninja.find_with_destroyed(:first).should == ninja

      # we're only interested in pirates who are alive by default
      pirate = Pirate.create(:name => 'Reginald')
      pirate.destroy
      Pirate.first.should be_blank
      Pirate.find_with_destroyed(:first).should == pirate

      # we're only interested in pirates who are dead by default.
      # zombie pirates ftw!
      DeadPirate.first.id.should == pirate.id
      lambda{
        DeadPirate.first.destroy
      }.should change(Pirate, :count).from(0).to(1)
    end
  end

  describe 'after_destroy and before_destroy callbacks' do
    it "should rollback if before_destroy fails" do
      edward = UndestroyablePirate.create(:name => 'Edward')
      lambda{
        edward.destroy
      }.should_not change(UndestroyablePirate, :count)
    end

    it "should rollback if after_destroy raises an error" do
      raul = RandomPirate.create(:name => 'Raul')
      lambda{
        begin
          raul.destroy
        rescue => ex
          ex.message.should == 'after_destroy works'
        end
      }.should_not change(RandomPirate, :count)
    end

    it "should handle callbacks normally assuming no failures are encountered" do
      component = Component.first
      lambda{
        component.destroy
      }.should change(component, :name).to(Component::NEW_NAME)
    end

  end
end