class PrescribedDaysMissed < ActiveRecord::Migration
  def self.up
ActiveRecord::Base.connection.execute <<EOF
DROP FUNCTION IF EXISTS prescribed_days_missed;
EOF

    ActiveRecord::Base.connection.execute <<EOF
CREATE FUNCTION prescribed_days_missed(start_date varchar(10),end_date varchar(10),dose double,quantity double) RETURNS INT 
DETERMINISTIC
BEGIN
DECLARE days INT;
DECLARE expected_remaining double;
DECLARE days_gone_since_dispension INT;
DECLARE run_out_date DATE;
DECLARE sDate DATE;
DECLARE eDate DATE;

set sDate = (SELECT DATE(start_date));
set eDate = (SELECT DATE(end_date));
set days_gone_since_dispension = (SELECT DATEDIFF(eDate,sDate));
set expected_remaining = (quantity - (dose*days_gone_since_dispension));
set run_out_date = (SELECT DATE_ADD(sDate, INTERVAL (quantity/dose) DAY));            

if expected_remaining >= 0 then set days = 0;
elseif expected_remaining < 0 then set days = (SELECT DATEDIFF(eDate,run_out_date)); 
end if;

RETURN days;
END;
EOF
  end

  def self.down
ActiveRecord::Base.connection.execute <<EOF
DROP FUNCTION IF EXISTS prescribed_days_missed;
EOF
  end
end
