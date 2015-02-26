Puppet::Type.newtype(:winsvc) do
  @doc = "Manages Windows services"

  ensurable do
    desc "Windows service install state."

    defaultvalues

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newproperty(:path) do
    desc "The path to the windows service"
  end

  newparam(:dotnetversion) do
    desc "the dotnetversion of installutil to use"
  end

  newparam(:sixtyfourbit) do
    desc "use 64 bit dotnet"
  end

  newparam(:method) do
    desc "use sc or installutil method"
    validate do |value|
      raise Puppet::Error, "method must not be empty" if value.empty?
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The Windows service name (case-sensitive)."
  end

end
