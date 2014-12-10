## 29-11-2014 - Release - 1.0.5
### Summary
- Fix a problem on the tomcat::deploy stage in case of hot deploy disabled
- This release add a new stage to the module, tomcat::uninstall, that allow to uninstall tomcat

## 26-10-2014 - Release - 1.0.4
### Summary
- This release add the possibility to add a DB driver to Tomcat lib folder and use it for the data source configuration in tomcat::setup stage
- The .erb templates file are now divided for Tomcat version (6,7 and 8 are supported)
- This release add optional SSL support in tomcat::setup stage
- This release add optional symbolic link to define context of a versioned .war package
- This release add the possibility to install tomcat as service
- This release add optional hot deploy in tomcat::deploy stage
- This release add a new stage to the module, tomcat::undeploy, that allow to undeploy a war package previously deployed on Tomcat

## 05-10-2014 - Release - 1.0.3
### Summary
- This release add the possibility to specify a particular context related to the deploying package
- This release add the possibility to deploy an external configuration directory related to the deploying package

## 14-09-2014 - Release - 1.0.2
### Summary
- This release add the tomcat users provisioning and make access log optional

## 18-08-2014 - Release - 1.0.1
### Summary
- This release add a new stage to the module, tomcat::deploy, that allow to deploy a war package to Tomcat
- Introducing Hiera in the Puppet Module for customization of data source and http, https, ajp ports and other properties

## 10-08-2014 - Release - 1.0.0
### Summary
- First Release
