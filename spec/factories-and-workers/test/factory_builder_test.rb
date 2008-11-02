require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class FactoryBuilderTest < Test::Unit::TestCase

  def metaclass; class << self; self; end; end

  def test_unknown_factory_raises_error
    e = assert_raises(NameError) do
      metaclass.class_eval do
        factory :foo, {}
      end
    end
    assert_equal "uninitialized constant ActiveRecord::Foo", e.message
  end

  def test_factory_with_initializer
    metaclass.class_eval do      
      factory :user, {
        :first_name => "Joe",
        :last_name  => "Blow"
      } do |u| u.email = "#{u.first_name}.#{u.last_name}@example.com".downcase end        
    end
    assert_equal "joe.doe@example.com", build_user( :last_name => 'Doe' ).email
  end

  def test_build_monkey_does_not_save
    assert_difference "Monkey.count", 0 do
      build_monkey
    end
  end 

  def test_create_monkey_does_save
    assert_difference "Monkey.count", 1 do
      create_monkey
    end
  end
  
  def test_valid_monkey_attributes
    assert_equal( {:name => "George"}, remove_variability( valid_monkey_attributes ) )
  end

  def test_valid_pirate_attributes_without_create_parents
    assert_difference "Monkey.count", 0 do
      valid_pirate_attributes( false )
    end
  end
  
  def test_valid_pirate_attributes_with_create_parents
    assert_difference "Monkey.count", 1 do
      valid_pirate_attributes( true )
    end
  end

  def test_valid_attribute__does_not_evaluate_other_attributes
    assert_difference "Monkey.count", 0 do
      assert_equal "Ahhrrrr, Matey!", valid_pirate_attribute(:catchphrase)
    end
  end

  def test_build_pirate
    assert_difference "Pirate.count", 0 do
      assert_difference "Monkey.count", 0 do
        build_pirate
      end
    end
  end

  def test_create_pirate_evaluates_lambda
    assert_difference "Pirate.count", 1 do
      assert_difference "Monkey.count", 1 do
        @pirate = create_pirate
      end
    end
    assert_equal @pirate.created_on.to_s, 1.day.ago.to_s
    sleep 1
    assert_not_equal create_pirate.updated_on.to_s, @pirate.updated_on.to_s
  end

  def test_ninja_pirate_is_silent_and_has_no_monkey
    assert_difference "Pirate.count", 1 do
      assert_difference "Monkey.count", 0 do
        @pirate = create_ninja_pirate
      end
    end
    assert_equal "(silent)", @pirate.catchphrase
  end
  
  def test_overridden_attributes
    @phil = create_monkey( :name => "Phil" )
    assert_not_equal valid_monkey_attribute(:name), @phil.name, "default monkey name should be overridden"

    assert_difference "Pirate.count", 0 do
      assert_difference "Monkey.count", 0 do
        @pirate = build_pirate( :monkey => @phil, :catchphrase => "chunky bacon!" )
      end
    end
    assert_not_equal valid_pirate_attribute(:catchphrase), @pirate.catchphrase, "default pirate catchphrase should be overridden"
    assert_equal "Phil", @pirate.monkey.name
    assert_equal "George", build_pirate.monkey.name
  end

  def test_overridden_attribute_id_will_not_evaluate_lambda_for_model_creation
    assert_difference "Monkey.count", 0 do
      @pirate = build_pirate( :monkey_id => 1 )
    end
  end

  def test_uniq_interpolation
    a = build_monkey.unique
    assert_equal 10, a.size

    b = build_monkey.unique
    assert_equal 10, b.size

    assert_not_equal a, b
  end

  def test_count_interpolation_not_interfered_with_by_external_counter
    assert_difference "build_monkey.counter.to_i", 1 do
      increment!(:foo)
    end
  end
  
  def test_increment!
    a = build_monkey.number
    assert_equal a+1, build_monkey.number
    assert_equal a+2, increment!(:foo)
    assert_equal a+3, build_monkey.number
  end
  
  def test_default_attributes_alias
    hash1 = remove_variability( valid_monkey_attributes )
    hash2 = remove_variability( default_monkey_attributes )
    assert_equal hash1, hash2
  end
  
  protected

  def remove_variability hash
    variable_attributes = [:unique, :counter, :number]
    returning hash do
      variable_attributes.each{ |a| hash.delete(a) }
    end
  end

end
