require 'csv'

class RalCsvParser
  def initialize(filename)
    @filename = filename
  end

  def process_file
    table = CSV.parse(File.read("#{@filename}.csv"), headers: true)
    table.each do |row|
      rgb = row["RGB"].split('-')
      rgb_formatted = "rgba(#{rgb[0]},#{rgb[1]},#{rgb[2]},1)"
      Ral.create(name: row["French"], name_en: row["English"], ref: row["RAL"], rgb: rgb_formatted, hex: row["HEX"])
    end
  end
end