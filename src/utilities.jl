path_separator() = if is_windows()
    ";"
else
    ":"
end

path_check(path) =
    if path == ""
        ""
    elseif ispath(path)
        path_separator() * path
    else
        info("Cannot find $path")
        ""
    end

platform_paths() = if is_windows()
    ["C:/Program Files/Git/usr/bin"]
else
    []
end

add_to_path(path) =
    "PATH" => string(ENV["PATH"], path_check.( vcat(platform_paths(), path) )...)

HTTP_wrapper(url_pieces...;
    request = HTTP.get,
    token = "",
    JSON_body = Dict(),
    body = "",
    activity = "",
    headers = Dict{String, String}(),
    status_exceptions = []
) = begin

    if activity != ""
        info(activity)
    end
    token_dict = if token != ""
        Dict("Authorization" => "token $token")
    else
        Dict{String, String}()
    end
    headers_and_token = merge(headers, token_dict)
    body_string = if JSON_body != Dict()
        JSON_body |> JSON.json |> string
    else
        body
    end
    retry = 1
    response = try
        request(string(url_pieces...),
            headers = headers_and_token,
            body = body_string)
    catch x
        if isa(x, HTTP.TimeoutException) && retry == 1
            retry = 0
            request(string(url_pieces...),
                headers = headers_and_token,
                body = body_string)
        else
            rethrow()
        end
    end
    status_number = response |> HTTP.status
    status_text = response |> HTTP.statustext
    response_body = response |> HTTP.body |> String
    if status_number in status_exceptions
        response
    elseif status_number >= 300
        error("$status_number $status_text: $response_body")
    else
        response_body |> JSON.Parser.parse
    end
end

ssh_keygen() = mktempdir() do temp
    cd(temp) do
        info("Generating ssh key")
        filename = ".documenter"
        if !success(`ssh-keygen -f $filename`)
            error("Cannot generate ssh keys")
        end
        string(filename, ".pub") |> readstring,
            filename |> readstring |> base64encode
    end
end
