/***
Class Name : JIRA_HTMLtoWIKIConverter
Desciption : This class is used to convert HTML to WIKI format
Date       : 26-Oct-2016
Author     : Suresh Babu Murugan
**/
public class JIRA_HTMLtoWIKIConverter {
    // This method is used to convert HTML to WIKI
    public static String convertHTMLtoWIKI(String HTMLDesc){
        system.debug(' HTML Description ===>'+HTMLDesc);
        if(HTMLDesc == null){
            return '';
        }
        
        // Convert Bold to "*"
        HTMLDesc = HTMLDesc.replaceAll('<b>', '*');
        HTMLDesc = HTMLDesc.replaceAll('</b>', '*');
        
        // Convert Italic to "_"
        HTMLDesc = HTMLDesc.replaceAll('<i>', '\\_');
        HTMLDesc = HTMLDesc.replaceAll('</i>', '\\_');
        
        // Convert Underline to "+"
        HTMLDesc = HTMLDesc.replaceAll('<u>', '+');
        HTMLDesc = HTMLDesc.replaceAll('</u>', '+');
        
        // Convert Stike to "-"
        HTMLDesc = HTMLDesc.replaceAll('<strike>', '-');
        HTMLDesc = HTMLDesc.replaceAll('</strike>', '-');
        
        // Convert <br> to "\r\n"
        //HTMLDesc = HTMLDesc.replaceAll('<br>', '\\\\\\\\');
        HTMLDesc = HTMLDesc.replaceAll('<br>', '\n');
        
        // Replace all Span tags 
        HTMLDesc = HTMLDesc.replaceAll('((<span.*?>)|(<span.*?">)|(<\\/span>))', '');
        
        // Replace all Div tags
        HTMLDesc = HTMLDesc.replaceAll('((<div.*?>)|(<div.*?">)|(<\\/div>))', '');
        
        // Replace all p tags
        HTMLDesc = HTMLDesc.replaceAll('((<p.*?>)|(<p.*?">)|(<\\/p>))', '');
        
        // Convert Link format
        Pattern aHrefPattern = Pattern.compile('(<a.*<\\/a>)');
        Matcher aHrefmat = aHrefPattern.matcher(HTMLDesc);
        
        List<String> lstLinks = new List<String>();
        while(aHrefmat.find()){
            lstLinks.add(aHrefmat.group());
        }
        system.debug(' ==>'+lstLinks);
        for(String link : lstLinks){
            String lName = link.substringAfter('>').substringBefore('</a>');
            String hLink = link.substringAfter('href="').substringBefore('"');
            if(hLink.contains('mailto')){
                // Replace all Links to Wiki Render format
                HTMLDesc = HTMLDesc.replace(link, '['+hLink+']');
            }
            else{
                // Replace all Links to Wiki Render format
                HTMLDesc = HTMLDesc.replace(link, '['+lName+'|'+hLink+']');
            }
            
        }
        
        // Convert Image format
        Pattern imagePattern = Pattern.compile('(<img.*<\\/img>)');
        Matcher imagemat = imagePattern.matcher(HTMLDesc);
        
        List<String> lstImages = new List<String>();
        while(imagemat.find()){
            lstImages.add(imagemat.group());
        }
        system.debug(' ==>'+lstImages);
        for(String img : lstImages){
            String imgURL = img.substringAfter('src="').substringBefore('"');
            String imgName = img.substringAfter('alt="').substringBefore('"');
            String imgStyle = img.substringAfter('style="').substringBefore('"').replaceAll(':', '=');
            
            system.debug('HTMLDesc ====================================================>>>'+HTMLDesc);
            
            if(imgStyle != ''){
                HTMLDesc = HTMLDesc.replace(img, ' !'+imgURL+'|'+imgStyle+'!');
            }
            else{
                HTMLDesc = HTMLDesc.replace(img, ' !'+imgURL+'!');
            }
        }
        
        // Convert Bullet Format
        HTMLDesc = HTMLDesc.replaceAll('\r\n', '<brd>'); // To make RegEx work properly converted back to <br>
        HTMLDesc = HTMLDesc.replaceAll('\n', '<brd>'); // Remove all enpty line breaks to make RegEx work properly
        Pattern p = Pattern.compile('(<ul.*<\\/ul>)');
        Matcher mat = p.matcher(HTMLDesc);
        List<String> lstBulletMatchedStrings = new List<String>();
        List<String> lstBulletConvertedStrings = new List<String>();
        system.debug('Description =============>'+HTMLDesc);
        while(mat.find()){
            system.debug('mat =============>'+mat);
            lstBulletMatchedStrings.add(mat.group());
        }
        system.debug('Matched Formt ==>'+lstBulletMatchedStrings);
        
        for(String matched: lstBulletMatchedStrings){
            system.debug(' ===>'+matched);
            Integer ulCount = matched.countMatches('<ul>');
            system.debug(' count ====>'+ulCount);
            matched = matched.replaceFirst('<ul>', '');
            matched = matched.replaceFirst('<li>', '<br>* ');
            if(ulCount > 1){
                system.debug(' More Updates ===>'+matched);
                
                Pattern pat = Pattern.compile('(<ul.*?<\\/ul>)');
                Matcher mt = pat.matcher(matched);
                
                List<String> lstSubBullet = new List<String>();
                while(mt.find()){
                    lstSubBullet.add(mt.group());
                }
                
                for(String subStr : lstSubBullet){
                    String subStrHTML = subStr;
                    system.debug('-First subStr----------------------->>>>'+subStr);
                    
                    subStr = subStr.replaceFirst('<ul><li>', '** ');
                    system.debug(' Before Replace ===> '+subStr);
                    subStr = subStr.replaceAll('<li>', '<br>** ');
                    //subStr = subStr.stripHtmlTags();
                    system.debug('-subStr----------------------->>>>'+subStr);
                    
                    matched = matched.replace(subStrHTML, subStr);
                }
            }
            system.debug('Before final ==>'+matched);
            //matched = matched.replaceFirst('<li>', '* ');
            matched = matched.replaceAll('<li>', '<br>* ');
            system.debug('Final ===>'+matched);
            //matched = matched.replaceAll('<br>', '\n'); // Return back to Line breaks
            matched = matched.stripHtmlTags();
            lstBulletConvertedStrings.add(matched + '<br>');
        }
        
        system.debug('matched string =======>'+lstBulletMatchedStrings);
        system.debug('Converted string =======>'+lstBulletConvertedStrings);
        system.debug('matched string =======>'+lstBulletMatchedStrings.size());
        system.debug('matched string =======>'+lstBulletConvertedStrings.size());
        
        for(integer i = 0; i < lstBulletMatchedStrings.size();i++){
            HTMLDesc = HTMLDesc.replace(lstBulletMatchedStrings[i], lstBulletConvertedStrings[i]);
        }
        
        
        // Convert Numbered Format
        HTMLDesc = HTMLDesc.replaceAll('\r\n', '<brd>'); // To make RegEx work properly converted back to <br>
        HTMLDesc = HTMLDesc.replaceAll('\n', '<brd>'); // Remove all enpty line breaks to make RegEx work properly
        Pattern numberedpat = Pattern.compile('(<ol.*<\\/ol>)');
        Matcher numberedmat = numberedpat.matcher(HTMLDesc);
        List<String> lstNumberedMatchedStrings = new List<String>();
        List<String> lstNumberedConvertedStrings = new List<String>();
        system.debug('Description =============>'+HTMLDesc);
        while(numberedmat.find()){
            system.debug('numberedmat =============>'+numberedmat);
            lstNumberedMatchedStrings.add(numberedmat.group());
        }
        system.debug('Matched Formt ==>'+lstNumberedMatchedStrings);
        
        for(String matched: lstNumberedMatchedStrings){
            system.debug(' ===>'+matched);
            Integer ulCount = matched.countMatches('<ol>');
            system.debug(' count ====>'+ulCount);
            matched = matched.replaceFirst('<ol>', '');
            matched = matched.replaceFirst('<li>', '<br># ');
            if(ulCount > 1){
                system.debug(' More Updates ===>'+matched);
                
                Pattern subNumberpat = Pattern.compile('(<ol.*?<\\/ol>)');
                Matcher subNumbermt = subNumberpat.matcher(matched);
                
                List<String> lstSubBullet = new List<String>();
                while(subNumbermt.find()){
                    lstSubBullet.add(subNumbermt.group());
                }
                
                for(String subStr : lstSubBullet){
                    String subStrHTML = subStr;
                    system.debug('-First subStr----------------------->>>>'+subStr);
                    
                    subStr = subStr.replaceFirst('<ol><li>', '## ');
                    system.debug(' Before Replace ===> '+subStr);
                    subStr = subStr.replaceAll('<li>', '<br>## ');
                    //subStr = subStr.stripHtmlTags();
                    system.debug('-subStr----------------------->>>>'+subStr);
                    
                    matched = matched.replace(subStrHTML, subStr);
                }
            }
            system.debug('Before final ==>'+matched);
            //matched = matched.replaceFirst('<li>', '# ');
            matched = matched.replaceAll('<li>', '<br># ');
            system.debug('Final ===>'+matched);
            //matched = matched.replaceAll('<br>', '\n'); // Return back to Line breaks
            matched = matched.stripHtmlTags();
            lstNumberedConvertedStrings.add(matched + '<br>');
        }
        
        system.debug('matched string =======>'+lstNumberedMatchedStrings);
        system.debug('Converted string =======>'+lstNumberedConvertedStrings);
        system.debug('matched string =======>'+lstNumberedMatchedStrings.size());
        system.debug('matched string =======>'+lstNumberedConvertedStrings.size());
        
        for(integer i = 0; i < lstNumberedMatchedStrings.size();i++){
            HTMLDesc = HTMLDesc.replace(lstNumberedMatchedStrings[i], lstNumberedConvertedStrings[i]);
        }
        
        HTMLDesc = HTMLDesc.replaceAll('<brd>', '\n'); // Return back to Line breaks
        HTMLDesc = HTMLDesc.replaceAll('<br>', '\n'); // Return back to Line breaks
        //HTMLDesc = HTMLDesc.replaceAll('@*', '\n'); // Return back to line breaks
        
        //Final Remove all HTML Tags
        //HTMLDesc = HTMLDesc.stripHtmlTags();
        //HTMLDesc = HTMLDesc.replaceAll('\\<.*?\\>', '');
        
        system.debug('WIKIRenderFormat ====>'+HTMLDesc);
        // returned WIKI Render format
        return HTMLDesc;
    }
    
    // This method is used to convert Wiki format to HTML
    public static String convertWIKItoHTML(String WikiFormatted){
        system.debug(' WIKI Description ===>'+WikiFormatted);
        if(WikiFormatted == null){
            return '';
        }
        
        
        // Convert "*" to Bold
        Pattern boldPattern = Pattern.compile('(\\*\\w.*\\*)');
        Matcher boldMat = boldPattern.matcher(WikiFormatted);
        
        List<String> lstBold = new List<String>();
        while(boldMat.find()){
            lstBold.add(boldMat.group());
        }
        
        for(String bld : lstBold){
            String HTMLbld = bld.replaceFirst('\\*', '<b>');
            HTMLbld = HTMLbld.substring(0, HTMLbld.length()-1) + '</b>';
            WikiFormatted = WikiFormatted.replace(bld, HTMLbld);
        }
        
        // Convert "_" to Italic
        Pattern italicPattern = Pattern.compile('(\\_.*\\_\\n)');
        Matcher italicMat = italicPattern.matcher(WikiFormatted);
        
        List<String> lstItalic = new List<String>();
        while(italicMat.find()){
            lstItalic.add(italicMat.group());
        }
        
        for(String itl : lstItalic){
            system.debug('itl ==========>'+itl);
            String HTMLitl = itl.replaceFirst('\\_', '<i>');
            HTMLitl = HTMLitl.substring(0, HTMLitl.length()-2) + '</i>\n';
            WikiFormatted = WikiFormatted.replace(itl, HTMLitl);
        }
        
        // Convert "+" to Underline
        Pattern underlinePattern = Pattern.compile('(\\+.*\\+)');
        Matcher underlineMat = underlinePattern.matcher(WikiFormatted);
        
        List<String> lstUnderlines = new List<String>();
        while(underlineMat.find()){
            lstUnderlines.add(underlineMat.group());
        }
        
        for(String udl : lstUnderlines){
            String HTMLudl = udl.replaceFirst('\\+', '<u>');
            HTMLudl = HTMLudl.substring(0, HTMLudl.length()-1) + '</u>';
            WikiFormatted = WikiFormatted.replace(udl, HTMLudl);
        }
        
        // Convert WIKI Link to HTML
        Pattern linkPattern = Pattern.compile('(\\[.*\\])');
        Matcher linkMat = linkPattern.matcher(WikiFormatted);
        
        List<String> lstLinks = new List<String>();
        while(linkMat.find()){
            lstLinks.add(linkMat.group());
        }
        
        for(String lik : lstLinks){
            String HTMLLink = lik.substringBetween('[', ']');
            if(HTMLLink.contains('|')){
                List<String> linkContent = HTMLLink.split('\\|'); // 0=> Name of Link, 1=> Link SRC
                system.debug('linkContent ====>'+linkContent);
                if(linkContent.size() > 1){
                    HTMLLink = '<a href="'+linkContent[1]+'" target="_blank">'+linkContent[0]+'</a>';
                }
                else if(linkContent.size() == 1){
                    HTMLLink = '<a href="'+linkContent[0]+'" target="_blank">'+linkContent[0]+'</a>';
                }
            }
            else{
                HTMLLink = '<a href="'+HTMLLink+'" target="_blank">'+HTMLLink+'</a>';
            }
            
            WikiFormatted = WikiFormatted.replace(lik, HTMLLink);
        }
        
        // Convert WIKI Image to HTML
        Pattern imagePattern = Pattern.compile('(\\!.*\\!)');
        Matcher imageMat = imagePattern.matcher(WikiFormatted);
        
        List<String> lstImages = new List<String>();
        while(imageMat.find()){
            lstImages.add(imageMat.group());
        }
        //!https://c.cs17.content.force.com/servlet/rtaImage?eid=a58g00000006HzT&feoid=00Ni000000FJvbH&refid=0EMg0000000mnQ6|height= 507px; width= 500px;!
        //<img alt="User-added image" src="http://www.w3schools.com/css/paris.jpg" style="height: 367px; width: 489px;"></img>
        
        for(String img : lstImages){
            String HTMLImage = img.substringBetween('!');
            if(HTMLImage.contains('|')){
                List<String> ImageContent = HTMLImage.split('\\|'); // 0=> Image URL, 1=> Style info
                system.debug('ImageContent ====>'+ImageContent);
                String styleStr = ImageContent[1].replaceAll('=', ':');
                HTMLImage = '<img alt="User-added image" src="'+ImageContent[0]+'" style="'+styleStr+'"></img>';
            }
            else{
                HTMLImage = '<img alt="User-added image" src="'+HTMLImage+'"></img>';
            }
            WikiFormatted = WikiFormatted.replace(img, HTMLImage);
        }
        
        // Convert <br> to "\r\n"
        WikiFormatted = WikiFormatted.replaceAll('\n', '<br>');
        
        system.debug('HTML Formatted ---====>'+WikiFormatted);
        return WikiFormatted;
    }
    
}