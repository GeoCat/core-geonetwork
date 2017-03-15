package nl.kadaster.pdok.test;
import org.junit.runner.RunWith;
import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * User: bloemj
 * Date: 17-7-2015
 * Time: 12:59
 */
@RunWith(SpringJUnit4ClassRunner.class)
@CucumberOptions(tags = {"~@not_implemented", "~@ignore"},
        //format = "pretty",
        features="classpath:features/")
public class RunTests {
}
