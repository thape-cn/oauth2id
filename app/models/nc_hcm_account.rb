class NcHcmAccount < ApplicationRecord
  establish_connection :nc_uap unless Rails.env.test?
  self.table_name = 'NC6337.HCM_ACCOUNT'
end
