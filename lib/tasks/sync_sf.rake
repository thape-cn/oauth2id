require 'net/sftp'

namespace :sync_sf do
  desc "Upload all data to SF"
  task :all => [:generate_hcm_psndoc_csv, :upload_thapeemployee_csv_to_production,
    :generate_hcm_background_csv, :upload_background_csv_to_production]

  desc 'Generate CSV file from hcm_psndoc'
  task :generate_hcm_psndoc_csv, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path] || "thapeemployee_#{Date.tomorrow.strftime("%m%d%Y")}.csv"

    CSV.open(csv_file_path, 'w') do |csv|
      csv << %w[STATUS USERID USERNAME FIRSTNAME LASTNAME MI GENDER EMAIL MANAGER
        HR DEPARTMENT JOBCODE DIVISION LOCATION TIMEZONE HIREDATE EMPID TITLE
        BIZ_PHONE FAX ADDR1 ADDR2 CITY STATE ZIP COUNTRY REVIEW_FREQ LAST_REVIEW_DATE
        CUSTOM01 CUSTOM02 CUSTOM03 CUSTOM04 CUSTOM05 CUSTOM06 CUSTOM07 CUSTOM08 CUSTOM09 CUSTOM10 CUSTOM11 CUSTOM12 CUSTOM13 CUSTOM14 CUSTOM15
        JOBFAMILY JOBLEVEL DEFAULT_LOCALE JOBROLE LOGIN_METHOD MATRIX_MANAGER]
      NcHcmPsndoc.all.each do |n|
        values = []
        values << n.status
        values << n.userid
        values << n.username
        values << n.firstname
        values << n.lastname
        values << n.mi
        values << n.gender
        values << n.email
        values << n.manager

        values << n.hr
        values << n.department
        values << n.jobcode
        values << n.division
        values << n.location
        values << n.timezone
        values << n.hiredate
        values << n.empid
        values << n.title

        values << n.biz_phone
        values << n.fax
        values << n.addr1
        values << n.addr2
        values << n.city
        values << n.state
        values << n.zip
        values << n.country
        values << n.review_freq
        values << n.last_review_date

        values << n.custom01
        values << n.custom02
        values << n.custom03
        values << n.custom04
        values << n.custom05
        values << n.custom06
        values << n.custom07
        values << n.custom08
        values << n.custom09
        values << n.custom10
        values << n.custom11
        values << n.custom12
        values << n.custom13
        values << n.custom14
        values << n.custom15

        values << n.jobfamily
        values << n.joblevel
        values << n.default_locale
        values << n.jobrole
        values << n.login_method
        values << n.matrix_manager

        csv << values
      end
    end
  end

  desc 'Upload thapeemployee CSV file to production'
  task :upload_thapeemployee_csv_to_production, [:thapeemployee_csv_path] => [:environment] do |_task, args|
    thapeemployee_csv_path = args[:thapeemployee_csv_path] ||"thapeemployee_#{Date.tomorrow.strftime("%m%d%Y")}.csv"
    host = Rails.application.credentials.sf_sftp_host!
    username = Rails.application.credentials.sf_sftp_username!
    password = Rails.application.credentials.sf_sftp_password!

    Net::SFTP.start(host, username, { password: password, append_all_supported_algorithms: true }) do |sftp|
      # upload a file or directory to the remote host
      sftp.upload!(thapeemployee_csv_path, "/test/#{thapeemployee_csv_path}")
    end
  end

  desc 'Generate CSV file from hcm_background'
  task :generate_hcm_background_csv, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path] || "Background_#{Date.tomorrow.strftime("%m%d%Y")}.csv"

    CSV.open(csv_file_path, 'w') do |csv|
      csv << %w[^UserID ^AssignmentId education startDate endDate
        academic school schoolqualification degree educationalsystem
        major way effectiveDate custcountry highest]
      NcHcmBackground.all.each do |b|
        values = []
        values << b.attributes['^UserId']
        values << b.attributes['^AssignmentId']
        values << b.education
        values << b.startDate
        values << b.endDate

        values << b.academic
        values << b.school
        values << b.schoolqualification
        values << b.degree
        values << b.educationalsystem

        values << b.major
        values << b.way
        values << b.effectiveDate
        values << b.custcountry
        values << b.highest


        csv << values
      end
    end
  end

  desc 'Upload background CSV file to production'
  task :upload_background_csv_to_production, [:background_csv_path] => [:environment] do |_task, args|
    background_csv_path = args[:background_csv_path] ||"Background_#{Date.tomorrow.strftime("%m%d%Y")}.csv"
    host = Rails.application.credentials.sf_sftp_host!
    username = Rails.application.credentials.sf_sftp_username!
    password = Rails.application.credentials.sf_sftp_password!

    Net::SFTP.start(host, username, { password: password, append_all_supported_algorithms: true }) do |sftp|
      # upload a file or directory to the remote host
      sftp.upload!(background_csv_path, "/test/#{background_csv_path}")
    end
  end
end
