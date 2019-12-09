class NcHcmPsndoc < ApplicationRecord
  establish_connection :nc_uap
  self.table_name = "NC6337.HCM_PSNDOC"
end
