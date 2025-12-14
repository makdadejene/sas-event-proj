class AddAllowedEmailsToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :allowed_emails, :text, array: true, default: []
  end
end
