require 'csv'

VALID_REASONS = %w(1 2 3 4 5 6 7 8 9 10 x1 x2 x3 x4).reverse.freeze

def remove_garbage(str)
  # remove spaces, leading zeroes, # and .
  str.gsub(/\s+/, '').gsub(/^0+/, '').gsub(/#+/, '').gsub(/\.+/, '')
end

def clean(reasons)
  reasons.map do |reason|
    if reason.to_s == ''
      nil
    elsif !VALID_REASONS.include?(reason)
      raise "Invalid reason found: [#{reason}]"
    else
      reason
    end
  end.compact
end

def parse(reasons)
  parsed = {}
  while reasons.length.nonzero?
    reason_found = false
    VALID_REASONS.each do |valid_reason|
      regex = /^#{valid_reason}/
      next if (regex =~ reasons).nil?
      return ['8'] if parsed[valid_reason] # duplicate number
      reason_found = true
      parsed[valid_reason] = true
      reasons = reasons.gsub(regex, '')
      break
    end
    return ['8'] unless reason_found # too much 0's
  end
  parsed.keys
end

def fix_reasons(reasons)
  res = if reasons.include?(',')
          reasons.split(',')
        elsif reasons.include?('/')
          reasons.split('/')
        elsif reasons == ''
          []
        else
          parse(reasons)
        end
  clean(res)
end

def fix_csv(file_name)
  file = File.open('fix_reasons.sql', 'w')
  csv = CSV.open(file_name, headers: true)
  csv.each do |row|
    result = fix_reasons(remove_garbage(row['retoure_reason']))
    file.write('UPDATE modo_orderarticle' \
               " SET retoure_reason = '#{result.join(',')}'" \
               " WHERE id = '#{row['id']}';\n")
  end
  file.close
  csv.close
end

puts 'Start processing csv file [corrupt_reasons.csv]'

fix_csv('corrupt_reasons.csv')

puts 'Finished processing csv file [corrupt_reasons.csv]'

# puts remove_blanks "4 10    "
# puts VALID_REASONS
