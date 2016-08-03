# begin end

- https://blog.newrelic.com/2014/11/13/weird-ruby-begin-end/
- Example in spearmint

```
def current_endorsement_request
  @current_endorsement_request ||=
    begin
      token = session[:endorsement].try(:[], :token)

      ProjectEndorsementRequest.find_by(token: token) if token
    end
end
```

- Seems like it's used to ensure lines 9 and 11 only run `if token`
- Kate killed this in PR https://github.com/experiment/experiment-prod/pull/6960/files
- So it may not be best practice