package org.fao.geonet.testservice;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Created by JuanLuis on 01/07/2015.
 */
@Controller
public class TestService {

    public
    @ResponseBody
    String test() {
        return "{'key': 'value'}";
    }
}
