package nl.kadaster.pdok.test;
import cucumber.api.PendingException;
import cucumber.api.java.en.And;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import jeeves.server.JeevesProxyInfo;
import jeeves.server.context.ServiceContext;
import org.apache.commons.httpclient.HostConfiguration;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;

import org.fao.geonet.AbstractCoreIntegrationTest;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.utils.ProxyParams;
import org.jdom.Element;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.Console;
import java.io.InputStream;

/**
 * User: bloemj
 * Date: 17-7-2015
 * Time: 10:58
 */
public class UploadThumbnailStepDefs extends  AbstractCoreIntegrationTest {

    static InputStream dataset;
    static InputStream icon;
    static String doc;
    ServiceContext context;
    @Autowired
    SettingManager settingManager;
    /** The default proxy port. */
    private static final int DEFAULTPROXYPORT = 8081;

    @Given("^a file stream containing the bytes from \"(.*?)\", an icon stream containing the \"(.*?)\" and the following metadata\\.$")
    public void a_file_stream_containing_the_bytes_from_an_icon_stream_containing_the_and_the_following_metadata(String arg1, String arg2, String arg3) throws Throwable {
        // Write code here that turns the phrase above into concrete actions
        dataset = ClassLoader.getSystemResourceAsStream(arg1);
        icon = ClassLoader.getSystemResourceAsStream(arg2);
        doc = arg3;
        setApplicationContextInApplicationHolder();
        setup();
    }

    @When("^the data is uploaded through the API\\.$")
    public void the_data_is_uploaded_through_the_API() throws Throwable {
        // Write code here that turns the phrase above into concrete actions
        throw new PendingException();
    }

    @Then("^the dataset is published\\.$")
    public void the_dataset_is_published() throws Throwable {
        // Write code here that turns the phrase above into concrete actions
        throw new PendingException();
    }

    /**
     * Sets the up proxy.
     *
     * @param client
     *            the new up proxy
     */
    private void setupProxy(final HttpClient client
            ,ServiceContext context) {
        try {
            // Detect and set up any proxy if specified using the
            // appropriate properties.
            // The properties http.proxyHost and http.proxyPort may be set,
            // for example in the J2EE server
            ProxyParams proxyParams = JeevesProxyInfo.getInstance().getProxyParams();
            GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
            SettingManager settingMan = settingManager;
            boolean useProxy = settingMan.getValueAsBool("system/proxy/use", false);
            if (useProxy) {
                String proxyServer = settingMan.getValue("system/proxy/host");
                String proxyPortProperty = settingMan.getValue("system/proxy/port");
                //String proxyServer = System.getProperty("http.proxyHost");
                //String proxyPortProperty = System.getProperty("http.proxyPort");
                // default to 8081, for example for Tomcat
                int proxyPort = DEFAULTPROXYPORT;
                if (proxyPortProperty != null) {
                    proxyPort = Integer.parseInt(proxyPortProperty);
                }
                if (proxyServer != null) {
                    HostConfiguration hostConfiguration =
                            client.getHostConfiguration();
                    hostConfiguration.setProxy(proxyServer, proxyPort);
                }
            }
        } catch (Throwable e) {
            throw new Error("Could net setup proxy." + e.getMessage());
        }
    }

    @Given("^the metadata is validated against the \"([^\"]*)\" validation.$")
    public void the_metadata_is_validated_against_the_validation(String validationUri) throws Throwable {

        Element response = new Element("response");
        PostMethod httpPost = new PostMethod(validationUri);
        httpPost.setRequestEntity(new StringRequestEntity(doc));
        httpPost.setParameter("Content-Type","text/xml");
        HttpClient client = new HttpClient();
        setupProxy(client, context);

        try {
            client.executeMethod(httpPost);

            // Process the response
            if (httpPost.getStatusCode() == HttpStatus.SC_OK) {

                String responseText = httpPost.getResponseBodyAsString();
                if (responseText.length() > 0) {
                    response.addContent(responseText);
                } else {
                    throw new Error("Validationresponse no responsetext");
                }
            } else {

                throw new Error("Validatie mislukt");
            }
        } catch (Exception e) {

            throw new Error("Error detected:" + e.getMessage());
        }
        httpPost.releaseConnection();
    }

    @And("^there is a usersession.$")
    public void there_is_a_usersession() throws Throwable {
        context = createServiceContext();
        loginAsAdmin(context);
    }
}
