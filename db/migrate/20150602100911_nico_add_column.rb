class NicoAddColumn < ActiveRecord::Migration
  def up
    adapter = connection.adapter_name.downcase
    if adapter == 'sqlite'
      # sqlite need default for not-null column
      add_column 'niconico_live_programs', 'cannot_recovery', :boolean, null: false, after: 'state', default: false 
      add_column 'niconico_live_programs', 'memo',            :text,    null: false, after: 'cannot_recovery', default: ''
    else
      add_column 'niconico_live_programs', 'cannot_recovery', :boolean, null: false, after: 'state'
      add_column 'niconico_live_programs', 'memo',            :text,    null: false, after: 'cannot_recovery'
    end
  end

  def down
    # remove_column 'niconico_live_programs', 'cannot_recovery'
    # remove_column 'niconico_live_programs', 'memo'
  end
end
