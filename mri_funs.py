#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  4 16:25:14 2019

@author: mikkel
"""

import pydicom

def which_scanner(fname):
    # Get manufacturer, model, and field strength of scanner for dicom file
    
    dcm = pydicom.read_file(fname)
    
    model = dcm.ManufacturerModelName
    mnfct = dcm.Manufacturer
    mfstr = dcm.MagneticFieldStrength
    
    print(mnfct+' '+model+', '+str(mfstr)+'T')
    
    
    
    
