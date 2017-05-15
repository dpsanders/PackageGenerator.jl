token_dict(any) = Dict("Authorization" => "token $(any.user_code)")
token_dict(a::AppVeyor) = Dict("Authorization" => "Bearer $(a.user_code)")

json_string(dict) =
    if dict == Dict()
        ""
    else
        dict |> JSON.json |> string
    end

http_json(response) = response |> HTTP.body |> String |> JSON.parse

http_error(response) = begin
    status_number = response |> HTTP.status
    status_text = response |> HTTP.statustext
    result_string = response |> HTTP.body |> String
    error("$status_number $status_text: $result_string")
end

talk_to(remote, url;
    request = HTTP.post, headers = token_dict(remote), body = Dict() ) = begin
    response = request(
        string(remote.url, url),
        headers = headers,
        body = json_string(body)
    )
    status_number = response |> HTTP.status
    if status_number >= 300
        response |> http_error
    else
        response
    end
end
