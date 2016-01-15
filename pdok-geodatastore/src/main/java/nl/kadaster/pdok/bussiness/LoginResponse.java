package nl.kadaster.pdok.bussiness;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;

/**
 * Created by juanluisrp on 01/12/2015.
 */
@JsonSerialize(include = JsonSerialize.Inclusion.NON_NULL)
public class LoginResponse {
    private boolean status;
    private String error;

    public LoginResponse(boolean status, String error) {
        this.status = status;
        this.error = error;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
}
