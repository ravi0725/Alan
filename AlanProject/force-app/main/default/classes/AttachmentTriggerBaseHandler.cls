public virtual with sharing class AttachmentTriggerBaseHandler {

	public List<Attachment> lstNewAttachment{
		get{
				if(lstNewAttachment == null)
					lstNewAttachment = new List<Attachment>();
				return lstNewAttachment;
		}set;
	}
	
	public Map<Id,Attachment> mapNewAttachment{
		get{
				if(mapNewAttachment == null)
					mapNewAttachment = new map<Id,Attachment>();
				return mapNewAttachment;
		}set;
	}
	
	public Map<Id,Attachment> mapOldAttachment{
		get{
				if(mapOldAttachment == null)
					mapOldAttachment = new map<Id,Attachment>();
				return mapOldAttachment;
		}set;
	}
	
	public List<Attachment> lstOldAttachment{
		get{
				if(lstOldAttachment == null)
					lstOldAttachment = new List<Attachment>();
				return lstOldAttachment;
		}set;
	}
	
	public AttachmentTriggerBaseHandler(List<Attachment> lstNewAttachment, List<Attachment> lstOldAttachment){
		this.lstNewAttachment = lstNewAttachment;
		this.lstOldAttachment = lstOldAttachment;
		
		mapNewAttachment.putAll(this.lstNewAttachment);
		mapOldAttachment.putAll(this.lstOldAttachment);
	}
	
	public virtual void execute()
	{
		
	}
}