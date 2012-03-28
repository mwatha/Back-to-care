class DrugOrder < ActiveRecord::Base
  set_table_name :drug_order
  set_primary_key :order_id
  belongs_to :drug, :foreign_key => :drug_inventory_id, :conditions => {:retired => 0}

  def order                                                                     
    @order ||= Order.find(order_id)                                             
  end

end
