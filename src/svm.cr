require "yaml"

private def output_help
  puts <<-HELP
  Usage: svm [update-type]

  Update types:
    patch         - Increments the last digit of the version
    minor         - Increments the middle digit of the version
    major         - Increments the first digit of the version
  HELP
  exit
end
raise "Failed to find ./shard.yml" unless File.exists?("./shard.yml")

shard_yml = File.read "./shard.yml"
raise "shard.yml does not contain a version field" if shard_yml["version"]?.nil?

output_help if ARGV.empty?
update_type = ARGV.shift

modified_shard : String = shard_yml.split('\n').map do |line|
  if line.starts_with?("version:")
    separated = line
      .split(':')
      .last
      .split('-')

    version_digits = separated
      .first
      .split('.')
      .map &.to_i32

    digit_idx = case update_type
    when "patch"
      2
    when "minor"
      1
    when "major"
      0
    else
      output_help
    end

    if version_digits[digit_idx]?.nil?
      raise "Cannot apply '#{update_type}' because the version is missing the corresponding digit to update"
    end

    version_digits[digit_idx] += 1
    new_version = version_digits.map(&.to_s).join('.') + (separated.size > 1 ? separated.last : "")
    "version: #{new_version}"
  else
    line
  end
end.join('\n')

File.write("./shard.yml", modified_shard)
