Puppet::Type.type(:winsvc).provide(:winsvc) do
  @doc = "Manages Windows services for Windows 2008R2 and Windows 7"

  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  C:\Windows\Microsoft.NET\Framework64\v4.0.30319
  
  if Puppet.features.microsoft_windows?

  if ENV.has_key?('ProgramFiles(x86)')
      commands :winsvc => "#{Dir::WINDOWS}\\Microsoft.NET\\Framework64\\v4.0.30319\\installutil.exe"
      commands :sc => "#{Dir::WINDOWS}\\sysnative\\sc.exe"
    else
      commands :winsvc => "#{Dir::WINDOWS}\\Microsoft.NET\\Framework\\v4.0.30319\\installutil.exe"
      commands :sc => "#{Dir::WINDOWS}\\system32\\sc.exe"
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    features = sc 'query', '| findstr /R "SERVICE_NAME:"'
    features = features.scan(/^SERVICE_NAME: ([\w-]+)/)
    features.collect do |f|
      new(:name => f[0], :state => 'Present')
    end
  end

  def flush
    @property_hash.clear
  end

  def create
    if ENV.has_key?('ProgramFiles(x86)')
      winsvc_cmd = "#{Dir::WINDOWS}\\Microsoft.NET\\Framework64\\v4.0.30319\\installutil.exe"
    else
      winsvc_cmd = "#{Dir::WINDOWS}\\Microsoft.NET\\Framework\\v4.0.30319\\installutil.exe""
    end

      output = execute([winsvc_cmd, "#{resource[:name]}")

    raise Puppet::Error, "Unexpected exitcode: #{$?.exitstatus}\nError:#{output}" unless resource[:exitcode].include? $?.exitstatus
  end

  def destroy
    winsvc '/u', "#{resource[:name]}"
  end

  def currentstate
    service = sc 'query', '| findstr /R',"#{resource[:name]}"
    service =~ /^SERVICENAME: (\w+)/
    $1
  end

  def exists?
    status = @property_hash[:state] || currentstate
    status == 'Present'
  end
end
