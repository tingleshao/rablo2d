load 'image_toolbox.rb'
 
 
 
testBinIm = generateBinary(128,20,15,64,64,0.0,0.0)
testPtLstIm = binaryToPointList(testBinIm, 128)
#~ puts testPtListImB
#puts testPtLstIm
dilTestPtLstIm = dilatePointList(testPtLstIm, 128,5,true)
dilBin = pointListToBinary(dilTestPtLstIm, 128)
displayBinary(dilBin, 128, 'testDil3')
#~ displayBinary(testBinIm, 128, 'testBeforeDil')