public class CleateCamController {

    public boolean screenConF {get;set;} //CleateCam画面の表示制御
    public boolean screenConF2 {get;set;} //CleateCam2画面の表示制御 True施策を実行　False 実行しない
    public String CamCanId {get;set;} //CampaignCandidate
    public List<CampaignCandidate__c> CamCanList {get;set;} //キェンペーン候補
    public List<CampaignMaster__c> CMList{get;set;} //キェンペーンマスタ

	Campaign InsCam2 = new Campaign(); //新規登録用のキャンペーン
    CampaignCandidate__c upCan = new CampaignCandidate__c();
    String SelectCam = null; //選択した施策の番号
    String SelectCamID = null; //選択した施策のSFID
    Map<String,String> cc = new Map<String,String>();//利用しない
   

    
    //コンストラクタ
    public CleateCamController(ApexPages.StandardController stdController){
    }




//CleateCam画面　初期処理
    public void ini(){
        CamCanId = ApexPages.currentPage().getParameters().get('id');
        CamCanSearch(CamCanId);
		cc.put('R011',CamCanList[0].CM1_SFID__c);
        cc.put('R012',CamCanList[0].CM2_SFID__c);
        cc.put('R013',CamCanList[0].CM3_SFID__c);
        cc.put('R014',CamCanList[0].CM4_SFID__c);
        cc.put('R015',CamCanList[0].CM5_SFID__c);
        cc.put('R020',CamCanList[0].CM5_SFID__c);
        SelectCam ='R011';
        screenConF=True; 
        if(CamCanList[0].handan__c =='R000'){
        	screenConF=False;            
        }
        system.debug('＊＊＊＊＊＊＊＊'+ScreenConF);
    }
    
//CleateCam２画面　初期処理
    public void ini2(){
        if(SelectCam !='R020'){
            screenConF2=true;
            SelectCamID = cc.get(SelectCam);
            //キャンペーンマスタの取得
            CMList = [select 
                                    id, 
                                    name, 
                                    ServiceTime__c,
                                    Contents__c,
                                    AllDay__c 
                                    From CampaignMaster__c 
                                    Where id =: SelectCamID limit 1];

            //キェンペーン初期値セット
            if(CMList.size()>0){
                InsCam2.name =CMList[0]. Contents__c;
                InsCam2.CM_SFID__c = CMList[0].id;
                InsCam2.YukoJikan__c = YukoJikanSet();
                InsCam2.YukoHizuke__c = CamCanList[0].BaseDate__c;
                InsCam2.StoreName__c =CamCanList[0].StoreSFID__c;
                InsCam2.CampaignCandidate__c =CamCanList[0].id;
                InsCam2.Status = 'In Progress';
                InsCam2.IsActive=true;
                system.debug('**********'+CamCanList[0].StoreSFID__c);
            }            
        }else{
           //施策にて「対象外」を選択している場合
			screenConF2=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '施策を実行しません'));
        }
            //キャンペーン候補
            upCan.id =CamCanList[0].id; //IDをセット
            upCan.handan__c =SelectCam; //判定の結果をセット

    }
    
    //キャンペーンの有効期限をセットする
    public time YukoJikanSet(){
        time t ;
        decimal xx = CMList[0].ServiceTime__c;

        if(CMList[0].AllDay__c){
            t = CamCanList[0].Close__c;
        }else{
        	t = CamCanList[0].BaseTime__c;
            xx = xx*1000*60*60;
            Integer f= integer.valueOf(xx);
            t=t+f;
        }
        return t;
    } 
     public Campaign getInsCam2(){
        return InsCam2;
    }                  

 
/*
 ラジオボタン処理
*/
    //表示の施策をセット
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('R011',CamCanList[0].Contents1__c)); 
        options.add(new SelectOption('R012',CamCanList[0].Contents2__c)); 
        options.add(new SelectOption('R013',CamCanList[0].Contents3__c));         
        options.add(new SelectOption('R014',CamCanList[0].Contents4__c)); 
        options.add(new SelectOption('R015',CamCanList[0].Contents5__c)); 
        options.add(new SelectOption('R020','実施しない')); 
        return options; 
    }
	//SelectCam Getter
    public String getSelectCam() {
        return SelectCam;
    }
    
    //SelectCam　Setter
    public void setSelectCam(String SelectCam) { 
        this.SelectCam = SelectCam; 
    }   
    
    
 /*
 アクション処理
*/
    //次のページへ
    public PageReference doNextPage() {
        return Page.CleateCam2.setRedirect(false);
    }
    //次のページへ
    public PageReference doBackpage() {
        return Page.CleateCam.setRedirect(false);
    }
    //登録
    public PageReference doActions() {
        try{
            update upCan;
            if(screenConF2){
                //「実施しない」以外で実行
                insert InsCam2;
            }
            PageReference camPage = new ApexPages.StandardController(InsCam2).view();
			camPage.setRedirect(true);
             return camPage;
        }catch(DmlException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'システムエラーが発生しました。'));
        }
        	return null;
    }
    
         //キャンペーン候補を取得する
	Public PageReference CamCanSearch (string CamCanId){
		CamCanList = [select 
                      id,
                      name,
                      handan__c,
                      StoreSFID__c,
                      BaseDate__c,
                      BaseTime__c,
                      Contents1__c, 
                      Contents2__c,
                      Contents3__c,
                      Contents4__c,
                      Contents5__c,
                      CM1_SFID__c,
                      CM2_SFID__c,
                      CM3_SFID__c,
                      CM4_SFID__c,
                      CM5_SFID__c,
                      Close__c
                      from campaignCandidate__c where id =: CamCanId limit 1] ;
    	return null;
	}
}