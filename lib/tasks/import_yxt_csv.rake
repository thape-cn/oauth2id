namespace :import_yxt_csv do
  desc 'Import the YXT positions to tables'
  task :positions, [:csv_file] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file]

    CSV.foreach(csv_file_path, headers: true) do |row|
      prefix_paths = row['PATH'].split('>')
      p_id = row['POSITIONNO']
      p_name = row['POSITIONNAME']

      YxtPosition.find_or_create_by!(id: p_id, prefix_paths: prefix_paths.join(';'), position_name: p_name)
    end
  end
end
