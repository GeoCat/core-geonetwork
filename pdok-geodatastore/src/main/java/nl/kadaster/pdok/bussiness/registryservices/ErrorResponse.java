package nl.kadaster.pdok.bussiness.registryservices;

import javax.xml.bind.annotation.XmlRootElement;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by juanluisrp on 27/01/2016.
 */
@XmlRootElement(name = "response")
public class ErrorResponse {
    private boolean error;
    private List<String> messages = new ArrayList<>();

    public boolean isError() {
        return error;
    }

    public void setError(boolean error) {
        this.error = error;
    }

    public List<String> getMessages() {
        return messages;
    }

    public void setMessages(List<String> messages) {
        this.messages = messages;
    }

    public void addMessage(String message) {
        messages.add(message);
    }
}
