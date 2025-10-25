# frozen_string_literal: true

namespace :webpacker do
  begin
    Rake::Task["webpacker:check_yarn"].clear
  rescue RuntimeError, NameError
    # Task not defined yet; nothing to clear.
  end

  desc "Verifies if pnpm is installed (replaces webpacker yarn check)"
  task :check_yarn do
    pnpm_version = `pnpm --version`.strip

    if pnpm_version.empty?
      $stderr.puts "pnpm not installed. Please install pnpm to compile webpacker assets."
      $stderr.puts "Exiting!"
      exit!
    end
  end
end
