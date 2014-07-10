module Puppet::Parser::Functions
  newfunction(:sql_archive, :type => :rvalue, :doc => <<-EOS
    Archives new SQL files to update Echoes Alert Database with new relations.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, 'sql_archive(): Wrong number of arguments ' +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    branch = arguments[1]
    path = arguments[0] + '/' + branch
    last_num = lookupvar('probe_sql_script_last_num')

    if last_num
      first, second, third = last_num.split('')
      first = first.to_i
      second = second.to_i
      third = third.to_i
    else
      first = 0
      second = 0
      third = 0
    end

    Dir.chdir(path)
    file_list = Dir['*.sql'].select {|x| x =~ /^(#{first}#{second}[#{third + 1}-9]|#{first}[#{second + 1}-9][0-9]|[#{first + 1}-9][0-9][0-9])_insert_*/ }.sort

    if file_list.any?
      filename = "#{arguments[0]}/last_num_#{lookupvar('hostname')}.txt" 
      File.open(filename, 'w+') { |file| file.write("probe_sql_script_last_num=#{file_list.last[0,3]}") } 
      `chmod 664 #{filemane}`
    end

    return Hash[file_list.map {|v| ['/tmp/' + v, Hash['branch', branch, 'source', v]]}]
  end
end

# vim: set ts=2 sw=2 et :
