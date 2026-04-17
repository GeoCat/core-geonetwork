package org.fao.geonet.repository;

import org.fao.geonet.domain.Setting;
import org.fao.geonet.domain.SettingDataType;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import javax.persistence.EntityManager;
import java.util.Optional;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class SettingRepositoryTest extends AbstractSpringDataTest {
    @Autowired
    private EntityManager em;

    @Autowired
    private SettingRepository repo;

    @Test
    public void testCreateASetting() {
        Setting setting = newSetting("test", SettingDataType.STRING, "testValue", 1, false);
        save(setting);

        Optional<Setting> savedSetting = repo.findById("test");

        assertTrue(savedSetting.isPresent());
        assertEquals(setting.getName(), savedSetting.get().getName());
        assertEquals(setting.getValue(), savedSetting.get().getValue());
        assertEquals(setting.getDataType(), savedSetting.get().getDataType());
    }

    @Test
    public void testUpdateASetting() {
        Setting setting = newSetting("test", SettingDataType.STRING, "testValue", 1, false);
        save(setting);

        Optional<Setting> savedSettingOpt = repo.findById("test");
        assertTrue(savedSettingOpt.isPresent());

        Setting savedSetting = savedSettingOpt.get();
        savedSetting.setValue("newValue");
        save(savedSetting);

        savedSettingOpt = repo.findById("test");
        assertTrue(savedSettingOpt.isPresent());

        Setting savedSettingUpdated = savedSettingOpt.get();

        assertEquals(savedSetting.getName(), savedSettingUpdated.getName());
        assertEquals(savedSetting.getValue(), savedSettingUpdated.getValue());
        assertEquals(savedSetting.getDataType(), savedSettingUpdated.getDataType());
    }

    @Test
    public void testUpdateASettingToEmptyValue() {
        Setting setting = newSetting("test", SettingDataType.STRING, "testValue", 1, false);
        save(setting);

        Optional<Setting> savedSettingOpt = repo.findById("test");
        assertTrue(savedSettingOpt.isPresent());

        Setting savedSetting = savedSettingOpt.get();
        savedSetting.setValue("");
        save(savedSetting);

        savedSettingOpt = repo.findById("test");
        assertTrue(savedSettingOpt.isPresent());

        Setting savedSettingUpdated = savedSettingOpt.get();

        assertEquals(savedSetting.getName(), savedSettingUpdated.getName());
        assertEquals(savedSetting.getValue(), savedSettingUpdated.getValue());
        assertEquals(savedSetting.getDataType(), savedSettingUpdated.getDataType());
    }
    
    private Setting newSetting(String key, SettingDataType type, String value, int position, boolean internal) {
        Setting setting = new Setting();
        setting.setDataType(type);
        setting.setName(key);
        setting.setPosition(position);
        setting.setValue(value);
        setting.setInternal(internal);

        return setting;
    }

    private void save(Setting setting) {
        repo.save(setting);
        // Ensures that the data is persisted in the database
        em.flush();
        // Empties 1st level cache, so find method retrieves the data from the database and listener PostLoad event is triggered
        em.clear();
    }

}
