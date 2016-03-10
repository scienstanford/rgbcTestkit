First install the OVTATPantherAM software to acquire images using the OmniVision RGBC testkit. 

This software only works in the Windows system.

(1), Install the exe file "PantherAM_08202014_3setup.exe"

(2), Place the OVD file "OV13850RGBCR2A_AM07_ID20.ovd" in the home_dir/OVTATPantherAM/OVDB directory
This file sets up default numbers for several parameters that the software automatically recognizes, e.g. how to crop raw images. The RGBC raw images are of high resolution thus only a cropping of an raw image is returned for transmission efficiency. Consult OmniVision engineers to change this file.  

(3), Place the ovpi file "RGBCAnaly.ovpi" in the home_dir/OVTATPantherAM/Init/Analy directory
This file is an add-on in the software, which can be used to plot the RGBC histgram of a selected region-of-interest. This add-on can be found in the software GUI as: Analysis->Custom ROI->RGBC Analysis ver 1.1

After installing the software, connect the laptop to the testkit board using USB line. 

Switch on the testkit board, which should be properly recognized by the software. No driver is needed (or the driver has been installed along with the software)

Read files in home_dir/OVTATPantherAM/OVTATPantherAM/UserGuide for how to use the software.

QT (c) Stanford VISTA
2016 March