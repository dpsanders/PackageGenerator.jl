ssh_keygen(ssh_keygen_file) = mktempdir() do temp
    cd(temp) do
        info("Generating ssh key")
        filename = ".documenter"
        try
            run(`$ssh_keygen_file -f $filename -N ""`)
        catch x
            if isa(x, Base.UVError)
                error("Cannot find ssh_keygen_file $ssh_keygen_file. See documentation of `configure` for platform specific recommendations")
            else
                rethrow()
            end
        end
        string(filename, ".pub") |> readstring,
            filename |> readstring |> base64encode
    end
end
