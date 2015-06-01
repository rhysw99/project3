CSV.foreach("postcodes.csv") do |row|
	hash = Hash.new
	hash[:postcode] = row[0]
	hash[:name] = row[1]
	hash[:latitude] = row[2]
	hash[:longitude] = row[3]
	Postcode.create(hash)
end
