class NcHcmBackground < ApplicationRecord
  establish_connection :nc_uap
  self.table_name = "NC6337.HCM_BACKGROUND_INFO"
end
