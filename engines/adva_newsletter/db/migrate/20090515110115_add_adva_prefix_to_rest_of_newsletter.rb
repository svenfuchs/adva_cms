class AddAdvaPrefixToRestOfNewsletter < ActiveRecord::Migration
  def self.up
    rename_table :cronjobs,    :adva_cronjobs
    rename_table :emails,      :adva_emails
    rename_table :newsletters, :adva_newsletters
  end

  def self.down
    rename_table :adva_cronjobs,    :cronjobs
    rename_table :adva_emails,      :emails
    rename_table :adva_newsletters, :newsletters
  end
end
