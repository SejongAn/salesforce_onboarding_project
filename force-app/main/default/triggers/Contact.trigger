/*******************************************************************************
* File Name   : Contact
        * Description : Contact
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.29  Yeongeun Kim     apply triggerFramework
* 1.0  2024.04.23  Yeongeun Kim     create
********************************************************************************/
trigger Contact on Contact (before insert,before update) {
    new Contact_tr().run();
}