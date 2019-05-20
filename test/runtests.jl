using msJ, Test

function tests()
    @testset "Subset of tests"  begin
        info = msJ.info("test.mzXML", verbose = true)
        @test info[1] == "parentFile: test.raw"                                        #1
        @test info[9] == "6 scans"                                                     #2
        @test info[10] == "MS1+"                                                       #3
        @test info[11] == "MS2+ 1255.5  CID(CE=18)"                                    #4
        @test info[12] == "MS3+ 902.33  PQD(CE=35)"                                    #5
        
        scans = msJ.load("test.mzXML")
        @test eltype(scans)              == msJ.MSscan                                 #6
        @test length(scans)              == 6                                          #7
        @test scans[1].num               == 1                                          #8
        @test scans[2].level             == 2                                          #9
        @test scans[3].polarity          == "+"                                        #10
        @test scans[2].activationMethod  == "CID"                                      #11
        @test scans[3].collisionEnergy   == 35.0                                       #12
        @test size(scans[1].int, 1)      == 22320                                      #13
        
        rt = msJ.retention_time("test.mzXML")
        @test length(rt) == 6                                                          #14
        
        rt, tic = msJ.chromatogram("test.mzXML", method = msJ.TIC() )
        @test length(rt) == 6                                                          #15
        
        rt, tic = msJ.chromatogram("test.mzXML", method = msJ.MZ([0, 500]))
        @test length(rt) == 6                                                          #16
        
        rt, tic = msJ.chromatogram("test.mzXML", method = msJ.∆MZ([1000, 1]))
        @test length(rt) == 6                                                          #17
        
        rt, tic = msJ.chromatogram("test.mzXML", method = msJ.BasePeak())
        @test length(rt) == 6                                                          #18
        
        xrt, xtic = msJ.chromatogram("test.mzXML", msJ.Polarity("+"), msJ.Scan(2),msJ.Precursor(1255.5), msJ.Activation_Energy(18), msJ.Activation_Method("CID"), msJ.Level(2) )
        @test length(xrt) == 1                                                         #19

        rt = msJ.retention_time(scans)
        @test length(rt) == 6                                                          #20
        
        rt, tic = msJ.chromatogram(scans, method = msJ.TIC() )
        @test length(rt) == 6                                                          #21
        
        rt, tic = msJ.chromatogram(scans, method = msJ.MZ([0, 500]))
        @test length(rt) == 6                                                          #22
        
        rt, tic = msJ.chromatogram(scans, method = msJ.∆MZ([1000, 1]))
        @test length(rt) == 6                                                          #23
        
        rt, tic = msJ.chromatogram(scans, method = msJ.BasePeak())
        @test length(rt) == 6                                                          #24
        
        xrt, xtic = msJ.chromatogram(scans, msJ.Polarity("+"),msJ.Scan(2),msJ.Precursor(1255.5),msJ.Activation_Energy(18),msJ.Activation_Method("CID"),msJ.Level(2) )
        @test (xrt, xtic) == ([0.7307], [9727.2])                                      #25
        
        xrt, xtic = msJ.chromatogram(scans, msJ.Polarity(["+"]),msJ.Scan([2,3]),msJ.Precursor([1255.5, 902.33]),msJ.Activation_Energy([18, 35]),msJ.Activation_Method(["CID", "PQD"]),msJ.Level([2, 3]) )
        @test (xrt, xtic) == ([0.7307, 2.1379], [9727.2, 11.3032])                     #26
        
        ms = msJ.msfilter("test.mzXML")
        @test length(ms.num) == 6                                                      #27
        
        ms = msJ.msfilter("test.mzXML", msJ.Polarity("+"),msJ.Scan(2),msJ.Precursor(1255.5),msJ.Activation_Energy(18),msJ.Activation_Method("CID"),msJ.RT(1),msJ.IC([0, 1e4]))
        @test ms isa msJ.MSscan                                                        #28
        @test ms.num == 2                                                              #29
                
        ms = msJ.msfilter(scans)
        @test length(ms.num) == 6                                                      #30
        
        ms = msJ.msfilter(scans, msJ.Polarity("+"),msJ.Scan(2),msJ.Precursor(1255.5),msJ.Activation_Energy(18),msJ.Activation_Method("CID"),msJ.RT(1),msJ.IC([0, 1e4]))
        @test ms isa msJ.MSscan                                                        #31
        @test ms.num == 2                                                              #32
        
        ms = msJ.msfilter(scans, msJ.Polarity(["+"]),msJ.Scan([2,3]),msJ.Precursor([1255.5, 902.33]),msJ.Activation_Energy([18, 35]),msJ.Activation_Method(["CID", "PQD"]),msJ.RT([1,2]),msJ.IC([0, 1e4]))
        @test ms isa msJ.MSscans                                                       #33
        @test ms.num == [2, 3]                                                         #34

        ms = msJ.msfilter("test.mzXML", msJ.RT( [[1,2], [2,3]] ), stats = false )
        @test ms isa msJ.MSscans                                                       #35
        @test ms.num == [2, 3, 4]                                                      #36

        ms = msJ.msfilter("test.mzXML", msJ.Polarity(["+"]),msJ.Scan([2,3]),msJ.Precursor([1255.5, 902.33]),msJ.Activation_Method(["CID", "PQD"]),msJ.RT([1,2]),msJ.IC([0, 1e4]))   #msJ.Activation_Energy([18., 35.]),
        @test ms isa msJ.MSscans                                                       #37
        @test ms.num == [2, 3]                                                         #38

        xrt, xtic = msJ.chromatogram("test.mzXML", msJ.Polarity(["+"]),msJ.Scan([2,3]),msJ.Precursor([1255.5, 902.33]),msJ.Activation_Method(["CID", "PQD"]),msJ.Level([2, 3]) )   #msJ.Activation_Energy([18.0, 35.0]),
        @test length(xrt) == 2                                                         #39

        ms = msJ.msfilter(scans, msJ.RT( [[1,2], [2,3]] ), stats = false )
        @test ms isa msJ.MSscans                                                       #40
        @test ms.num == [2, 3, 4]                                                      #41

        a = scans[1] / 2.
        @test a.tic == 2.540975e6                                                      #42

        a = scans[1] * 2.
        @test a.tic == 1.01639e7                                                       #43

        a = ms * 2.
        @test a.tic == 3.2120923354666666e6                                            #44

        a = 2. * scans[1]
        @test a.tic == 1.01639e7                                                       #45

        a = scans[1] * scans[2]
        @test a.tic == 4.943314404e10                                                  #46

        a = scans[2] * scans[1]
        @test a.tic == 4.943314404e10                                                  #47

        a = scans[1] - scans[2]
        @test a.tic == 5.0722228e6                                                     #48

        a = scans[2] - scans[1]
        @test a.tic == -5.0722228e6                                                    #49

        a = scans[1] - scans[4]
        @test a.tic == 273550.0                                                        #50

        b = ms - scans[1]
        @test b.num == [2,3,4]                                                         #51

        b = ms + scans[1]
        @test b.num == [2,3,4,1]                                                       #52

        b = scans[1] + ms 
        @test b.num == [1,2,3,4]                                                       #53

        b = scans[1] + scans[4] 
        @test b.num == [1,4]                                                           #54

        a = msJ.avg(scans[1], scans[2])
        @test a.num == [1,2]                                                           #55

        a = msJ.avg(scans[1], scans[4])
        @test a.num == [1,4]                                                           #56

        info = msJ.info("test64.mzXML")
        @test info[2] == "MS1-"                                                        #57
        
        scans = msJ.load("test64.mzXML")
        @test eltype(scans)              == msJ.MSscan                                 #58

        info = msJ.info("test.mzXMLM")
        @test info.msg == "File format not supported."                                 #59

        scans = msJ.load("test.mzXMLL")
        @test info.msg == "File format not supported."                                 #60

        scans = msJ.load("bad1.mzXML")
        @test scans.msg == "Not an mzXML file."                                        #61

        scans = msJ.info("bad1.mzXML")
        @test scans.msg == "Not an mzXML file."                                        #62

        scans = msJ.load("bad2.mzXML")
        @test scans[1].num == 0                                                        #63

        scans = msJ.load("bad3.mzXML")
        @test scans[1].num == scans[2].num == 0                                        #64

        rt, tic = msJ.chromatogram("test.mzXML", method = msJ.∆MZ([1, 2]))
        @test rt.msg == "Bad mz ± ∆mz values."                                         #65
        
        rt, tic = msJ.chromatogram(scans, method = msJ.∆MZ([1, 2]))
        @test rt.msg == "Bad mz ± ∆mz values."                                         #66

        scans = msJ.load("test.mzXML")
        @test msJ.smooth(scans[1], method = msJ.SG(7,15)) isa msJ.MSscan               #67

        a = msJ.avg(scans[1], scans[4])
        @test msJ.smooth(a) isa msJ.MSscans                                            #68

        a = scans[1] * scans[4]
        @test a.num == [1,4]                                                           #69

        a = (scans[2]+scans[3]) - scans[1]
        @test a.num == [2, 3]                                                          #70

        a = (scans[1] + scans[4]) - (scans[1] - scans[4])
        @test a.num == [1, 4]                                                          #71

        a = scans[1] + msJ.avg(scans[2], scans[5])
        @test a.num == [1, 2, 5]                                                       #72

        a = msJ.smooth(scans[1], method = msJ.SG(5,9))
        @test a.num == 1                                                               #73

       a = msJ.centroid(scans[1], method = msJ.TBPD(:gauss, 4500., 0.2))                    #74
       @test length(a.int) == 703

    end
end
tests()
