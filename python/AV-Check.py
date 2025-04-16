import psutil

# Liste des exécutables AV les plus courants
av_process_names = [
    "MsMpEng.exe", "AdAwareService.exe", "afwServ.exe", "avguard.exe", "AVGSvc.exe", 
    "bdagent.exe", "BullGuardCore.exe", "ekrn.exe", "fshoster32.exe", "GDScan.exe", 
    "avp.exe", "K7CrvSvc.exe", "McAPExe.exe", "NortonSecurity.exe", "PavFnSvr.exe", 
    "SavService.exe", "EnterpriseService.exe", "WRSA.exe", "ZAPrivacyService.exe"
]

def check_av_processes():
    print("[+] Antivirus check is running ..\n")
    found = False

    # Parcours de tous les processus en cours
    for proc in psutil.process_iter(['name']):
        try:
            proc_name = proc.info['name']
            if proc_name in av_process_names:
                print(f"-- AV Found: {proc_name}")
                found = True
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue

    if not found:
        print("-- No AV software detected.")

if __name__ == "__main__":
    check_av_processes()
