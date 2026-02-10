namespace :ral do
  desc "Import RAL Design depuis le CSV à la racine"
  task import_design: :environment do
    RalDesignCsvParser.new("ral-design").process_file
    puts "✅ Import RAL Design terminé"
  end
end
