package nl.kadaster.pdok.bussiness;

import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.schema.iso19139.ISO19139SchemaPlugin;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.nio.file.Path;
import java.util.Map;

/**
 * Created by JuanLuis on 09/07/2015.
 */
@Service
public class MetadataUtil {

    public static final String TEMPLATE_FILE = "templates/pdok-datastore-template.xml";
    private static final java.lang.String NEW_FILE_STYLESHEET_FILE = "geodatastore-new-upload.xsl";
    @Autowired
    private SchemaManager schemaManager;


    public Element fillXmlTemplate(Map<String, Object> parameters) throws Exception {
        Resource resource = new ClassPathResource(TEMPLATE_FILE);
        InputStream resourceInputStream = resource.getInputStream();
        Element template = Xml.loadStream(resourceInputStream);
        return updateMetadataContents(parameters, template);
    }

    public Element updateMetadataContents(Map<String, Object> parameters, Element oldMetadata) throws Exception {
        Path xsltTransform = schemaManager.getSchemaDir(ISO19139SchemaPlugin.IDENTIFIER).resolve("process/")
                .resolve(NEW_FILE_STYLESHEET_FILE);
        Element result = Xml.transform(oldMetadata, xsltTransform, parameters);

        return result;
    }

}
