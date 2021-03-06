class PapertrailOutputProcessor
  def process_lines(path)
    IO.foreach(path).map { |line| entry_from_line(line) }
  end

  def entry_from_line(line)
    # papertrail prefixes Bike Index's log output lines with a time,
    # a name of the server and name of the logfile
    parsed = JSON.parse(line.gsub(/\A[^{]*/, ''))
    return parsed if parsed['@timestamp']
    # If the line doesn't include @timestamp, put it in from papertrail's prefixed time
    # Force UTC timezone
    time = line[/\A\w*\s\d*\s\d[^\s]*/]
    parsed.merge('@timestamp' => "#{time}Z")
  end

  def create_log_lines(path)
    process_lines(path).each do |entry|
      LogLine.create_log_line(entry)
    end
  end

  def create_log_lines_from_events(events_array)
    events_array.each do |entry|
      parsed_log = JSON.parse(entry[:message])
      unless parsed_log.include?('@timestamp')
        parsed_log['@timestamp'] = "#{entry[:received_at]}Z"
      end
      LogLine.create_log_line(parsed_log)
    end
  end
end
