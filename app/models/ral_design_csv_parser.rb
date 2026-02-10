require "csv"

class RalDesignCsvParser
  def initialize(filename)
    @filename = filename
  end

  def process_file
    path  = Rails.root.join("#{@filename}.csv")
    table = CSV.parse(File.read(path), headers: true)

    table.each do |row|
      ref = row['code_ral']
      name = row['name_fr']
      rgba = row['rgba']
      hex = row['hex']

      ral = Ral.find_or_initialize_by(ref: ref)
      ral.name ||= name
      ral.rgb = rgba
      ral.hex = hex
      ral.collection = 'design'
      ral.save!
    end
  end
end
