-ifndef(EXTDEC_HRL).
-define(EXTDEC_HRL, true).

-record(protocolErrors,{
	  invalidManIE=false,
	  outOfSequence=false,
	  incorrectOptIE=false}).
-record(mvsT_msisdn, {value}).
-record(mvsT_isdnAddress, {value}).
-record(mvsT_hlrAddress, {value}).
-record(mvsT_authenticationTriplet, {rand, sres, kc}).
-record(mvsT_authenticationQuintuplet, {rand, xres, ck, ik, autn}).
-record(mvsT_resynchInfo, {rand, auts}).
-record(mvsT_resynch, {label, value}).
-record(mvsT_storeImsiFault, {label, value}).
-record(mvsT_additionalImsisResults, {roamingStatus, defaultApnOperatorId, misc1, misc2, misc3}).
-record(mvsT_pdpActiveRecord, {contextId, nsapi, pdpTypeReq, pdpAddrReq, apnReq, qosReq, pdpTypeInUse, pdpAddressNature, pdpAddressInUse, apnInUse, ggsnAddrInUse, qosNegotiated}).
-record(mvsgT_rai, {mcc, mnc, lac, rac}).
-record(mvsgT_lai, {mcc, mnc, lac}).
-record(mvsgT_errorInd, {dummyElement}).
-record(mvsgT_deleteRes, {cause}).
-record(mvsgT_deleteReq, {dummyElement}).
-record(mvsgT_ptmsi, {value}).
-record(mvsgT_ddRef, {cid, extId, validity}).
-record(mvsgT_dpRef, {cid, devId}).
-record(mvsgT_qualityOfService, {delayClass, relClass, peakThrput, precClass, meanThrput}).
-record(mvsgT_pdpAddressType, {pdpTypeNbr, address}).
-record(mvsgT_msNetworkCapability, {gea1, smCapDediccatedChannel, smCapGprsChannel, ucs2Support, ssScreenInd}).
-record(mvsgT_cellId, {mcc, mnc, lac, rac, ci}).
-record(mvsgT_ipAddress, {version, a1, a2, a3, a4, a5, a6, a7, a8}).
-record(mvsgT_restartContextData, {gsn_address, restart_counter}).
-record(mvsgT_updateRes, {cause, qos, ggsnAddSig, ggsnAddUser, recovery, flowLabDataI, flowLabSig, chargId, optFlags}).
-record(mvsgT_updateReq, {qos, sgsnAddSig, sgsnAddUser, recovery, flowLabDataI, flowLabSig, otpFlags}).
-record(mvsgT_imsi, {value}).
-record(mvsgT_tid, {imsi, nsapi}).
-record(mvsgT_extQualityOfService, {allocRetention, trfClass, delOrder, delOfErrSDU, maxSDUSize, maxBRUp, maxBRDown, residualBER, sduErrorRatio, transferDelay, traffHandlPrio, guarBRUp, guarBRDown}).
-record(mvsgT_qualServ, {label, value}).
-record(sesT_gnDevContextData, {numberOfContext, recoveryInfoArray}).
-record(sesT_tid, {imsi, nsapi}).
-record(sesT_gnDevContextDataInfo, {dummy}).
-record(sesT_teid, {value}).
-record(sesT_qualityOfServiceV1, {allocRetPriority, delayClass, reliabilityClass, peakThroughput, precedenceClass, meanThroughput, trafficClass, deliveryOrder, delivOfErrSDU, maxSDUsize, maxBrUp, maxBrDown, residualBER, sduErrorRatio, transferDelay, trafficHandlPrio, guaranteedBrUp, guaranteedBrDown}).
-record(sesT_flowLbl, {value}).
-record(sesT_qualityOfServiceV0, {delayClass, reliabilityClass, peakThroughput, precedenceClass, meanThroughput}).
-record(sesT_createReq, {dummy}).
-record(sesT_createRes, {dummy}).
-record(sesT_deleteReq, {dummy}).
-record(sesT_deleteRes, {dummy}).
-record(sesT_gtid, {imsi, nsapi}).
-record(sesT_updateReq, {dummy}).
-record(sesT_updateRes, {dummy}).
-record(sesT_gcontrolDataUs, {gtpSeqNr, gsnAddress, gtunnelId, gsnPort}).
-record(sesT_gcontrolDataDs, {gtpSeqNr, gsnAddress, protocol, gtunnelId, flowLabSig, gsnPort}).
-record(sesT_createResV1, {cause, teidSignalling, teidData, ggsnAddSig, ggsnAddUser, reorderingReq, recovery, chargId, endUserAdd, optFlags, protConOpt, qos}).
-record(sesT_createReqV1, {qos, sgsnAddSig, sgsnAddUser, selMode, recovery, msisdn, endUserAdd, accPointName, optFlags, protConOpt, imsi, teidData, teidSignalling, nsapi}).
-record(sesT_deleteReqV1, {teardownInd, nsapi}).
-record(sesT_deleteResV1, {cause}).
-record(sesT_updateReqV1, {imsi, recovery, teidData, teidSignalling, nsapi, sgsnAddSig, sgsnAddUser, qos}).
-record(sesT_updateResV1, {cause, recovery, teidData, teidSignalling, chargId, ggsnAddSig, ggsnAddUser, qos}).
-record(sesT_deleteReqV0, {tid}).
-record(sesT_deleteResV0, {tid, cause}).
-record(sesT_createReqV0, {tid, tidRaw, qos, recovery, selMode, flowLblData, flowLblSig, endUserAdd, accPointName, protConOpt, sgsnAddSig, sgsnAddUser, msisdn}).
-record(sesT_createResV0, {tid, cause, qos, reorderingReq, recovery, flowLblData, flowLblSig, chargId, endUserAdd, protConOpt, ggsnAddSig, ggsnAddUser}).
-record(sesT_updateReqV0, {tid, tidRaw, qos, recovery, flowLblData, flowLblSig, sgsnAddSig, sgsnAddUser}).
-record(sesT_updateResV0, {tid, cause, qos, recovery, flowLblData, flowLblSig, chargId, ggsnAddSig, ggsnAddUser}).
-record(sesT_echoReq, {dummy}).
-record(sesT_echoRes, {dummy}).
-record(sesT_echoReqV1, {dummy}).
-record(sesT_echoResV1, {recovery}).
-record(sesT_echoReqV0, {dummy}).
-record(sesT_echoResV0, {recovery}).
-record(masT_apnSecurity, {sgsnSel, subscribedSel, userSel, ipSpoofing}).
-record(masT_radiusServer, {radiusApn, radiusAddress, radiusMepAddress, timer, tries, secret}).
-record(masT_ipSegment, {startSegAddress, stopSegAddress, netmask}).
-record(masT_llf, {name, metric, id}).
-record(masT_apnLink, {ggsnAddress, ipSegList, ipAddressOrigin, llfConnName, mepAddress}).
-record(masT_ispSubObj, {label, value}).
-record(masT_ipcpData, {type, ipAddress, rawMessage}).
-record(masT_ipcp, {exists, code, id, ipcpList}).
-record(masT_pap, {exists, code, id, username, password}).
-record(masT_chap, {code, id, value, name}).
-record(masT_ispDevContextData, {nsapi, ipAddress, apnhandle}).
-record(masT_protocolConfigOptions, {chap, pap, ipcp}).
-record(masT_apnRadius, {radiusAddress, timer, tries, secret}).
-record(masT_outbandRadius, {gwAddress, llfConnName, primRadius, secRadius}).
-record(masT_radiusPair, {primRadius, secRadius}).
-record(masT_radiusOpt, {dummyMsisdnAuth, dummyMsisdnAcct, msisdnInAuth, msisdnInAcct, sendFullImsi, sendMccMnc, sendSelMode, sendChargingId, asynchAcct}).
-record(masT_radiusConfig, {hostApn, authPair, acctList, radiusOptions}).
-record(masT_apnConfig, {link, security, radiusConfig, primDns, secDns, dhcpAddress, indAcct, indAuth, userNameBasedSelection}).


-endif.