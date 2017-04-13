HTTP_wrapper(url_pieces...;
    request = HTTP.get,
    token = "",
    JSON_body = Dict(),
    body = "",
    activity = "",
    headers = Dict{String, String}(),
    status_exceptions = [],
    retry = 1
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
        if isa(x, HTTP.TimeoutException) && retry > 0
            info("Timeout; retrying")
            return HTTP_wrapper(url_pieces...;
                request = request,
                token = token,
                JSON_body = JSON_body,
                body = body,
                activity = activity,
                headers = headers,
                status_exceptions = status_exceptions,
                retry = retry - 1
            )
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
        try
            response_body |> JSON.parse
        catch
            response_body
        end
    end
end

ssh_keygen(path) = mktempdir() do temp
    cd(temp) do
        info("Generating ssh key")
        filename = ".documenter"
        succeded = try
            success(`$path -f $filename`)
        catch x
            if isa(x, Base.UVError)
                error("Cannot find ssh-keygen`")
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
