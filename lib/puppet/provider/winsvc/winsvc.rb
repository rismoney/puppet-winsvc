Puppet::Type.type(:winsvc).provide(:winsvc) do
  @doc = "Manages Windows services for Windows 2008R2 and Windows 7"

  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  if Puppet.features.microsoft_windows?

  if ENV.has_key?('ProgramFiles(x86)')
   commands :sc => "#{Dir::WINDOWS}\\sysnative\\sc.exe"
  else
   commands :sc => "#{Dir::WINDOWS}\\system32\\sc.exe"
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
    basedir = "#{Dir::WINDOWS}\\Microsoft.NET\\"
    if @resource[:sixtyfourbit]
      commands :winsvc => "#{basedir}Framework64\\v#{@resource[:dotnetversion]}\\installutil.exe"
    else
      commands :winsvc => "#{basedir}Framework\\v#{@resource[:dotnetversion]}\\installutil.exe"
    end

    output = execute([winsvc_cmd, "#{resource[:name]}")
    raise Puppet::Error, "Unexpected exitcode: #{$?.exitstatus}\nError:#{output}" unless resource[:exitcode].include? $?.exitstatus
  end

  def destroy
    winsvc '/u', "#{@resource[:name]}"
  end

  def currentstate
    service = sc 'query', '| findstr /R',"#{@resource[:name]}"
    service =~ /^SERVICENAME: (\w+)/
    $1
  end

  def exists?
    status = @property_hash[:state] || currentstate
    status == 'Present'
  end
end
