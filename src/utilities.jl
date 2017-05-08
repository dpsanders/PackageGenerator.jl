HTTP_wrapper(url_pieces...;
    request = HTTP.get,
    token = "",
    body = Dict(),
    headers = Dict{String, String}(),
    status_exceptions = [],
    retry = 1
) = begin

    headers_with_token = if token != ""
        merge(headers, Dict("Authorization" => "token $token") )
    else
        headers
    end
    body_string = if body != Dict()
        body |> JSON.json |> string
    else
        ""
    end
    response = try
        request(string(url_pieces...),
            headers = headers_with_token,
            body = body_string)
    catch x
        if isa(x, HTTP.TimeoutException) && retry > 0
            info("Timeout; retrying")
            return HTTP_wrapper(url_pieces...;
                request = request,
                token = token,
                body = body,
                headers = headers,
                status_exceptions = status_exceptions,
                retry = retry - 1
            )
        else
            rethrow()
        end
    end

    status_text = response |> HTTP.statustext

    content_type =
        if status_text == "No Content"
            "No Content"
        else
            response.headers["Content-Type"]
        end

    result_body = response |> HTTP.body

    result_string =
        if content_type == "image/png"
            ""
        else
            result_body |> String
        end

    status_number = response |> HTTP.status

    if status_text in status_exceptions
        status_text
    elseif status_number >= 300
        error("$status_number $status_text: $result_string")
    else
        if content_type in ("application/json; charset=utf-8", "application/json;charset=utf-8", "application/json")
            result_string |> JSON.parse
        elseif content_type in ("No Content", "text/plain; charset=utf-8")
            result_string
        elseif content_type == "image/png"
            result_body
        else
            error("Cannot find content_type $content_type")
        end
    end
end

ssh_keygen(ssh_keygen_file) = mktempdir() do temp
    cd(temp) do
        info("Generating ssh key")
        filename = ".documenter"
        succeded = try
            success(`$ssh_keygen_file -f $filename`)
        catch x
            if isa(x, Base.UVError)
                error("Cannot find ssh_keygen_file $ssh_keygen_file. See documentation of `PackageGenerator.generate` for platform specific recommendations")
            else
                rethrow()
            end
        end
        if !succeded
            error("Cannot generate ssh keys")
        end
        string(filename, ".pub") |> readstring,
            filename |> readstring |> base64encode
    end
end

default_appveyor_slug(repo_name) = replace(lowercase(repo_name), ".", "-")
