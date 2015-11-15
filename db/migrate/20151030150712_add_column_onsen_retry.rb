class AddColumnOnsenRetry < ActiveRecord::Migration
  def up
    add_column 'onsen_programs', 'retry_count', :integer, null: false, unsigned: true, after: 'state', default: 0
  end

  def down
    # remove_column 'onsen_programs', 'retry_count'
  end
end
