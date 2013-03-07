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

  newparam(:name, :namevar=>true) do
    desc "The Windows service name (case-sensitive)."
  end

end
