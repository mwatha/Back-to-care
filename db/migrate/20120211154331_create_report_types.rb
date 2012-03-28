class CreateReportTypes < ActiveRecord::Migration
  def self.up
    create_table :report_types do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :report_types
  end
end
