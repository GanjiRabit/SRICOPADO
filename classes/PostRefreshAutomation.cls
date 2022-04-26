global class PostRefreshAutomation implements InstallHandler 
{
    global void onInstall(InstallContext context) 
        {
            testmethod1();
            /*updateEmail();
            resetPassword();
            String currentUserId = UserInfo.getName();
            if(currentUserId == 'DateChecker') //Verifying the logged user, we can also use custom labels instead
            {
               dateCheckerScheduleJobs();
            }
            else if(currentUserId == 'salesFadmin')
            {
               salesFAdminScheduleJobs();
            }*/
        }
            public static void testmethod1()
            {
            system.debug('Test');
            }
            /*------------------------------------------------------------
            Description:   To get all invalid email ids and remove .invalid at the end
            ------------------------------------------------------------*/
           /* public static void updateEmail()
            {
                String target = '.invalid';
                String replacement = '';
                
                List<User> users = new List<User>();
                users = [Select id, Email from user where email like '%invalid%' and isactive = true];
                try{
                    if(users.size()>0)
                    {
                        for(User u:users)
                        {
                            u.Email.replace(target, replacement);
                        }
                    }
                }
                catch(Exception e){
                }
                system.debug('users'+users);
                update users;
            }*/
            
            /*------------------------------------------------------------
            Description:   To reset password for all active users and valid emails
            ------------------------------------------------------------*/
            /*public static void resetPassword()
            {
                List<User> users = new List<User>();
                users = [Select id, Email from user where email like '%invalid%' and isactive = true];
                if(users.size()>0)
                {
                    for(User u:users)
                    {
                        System.resetPassword(u.Id, true);
                    }
                }
                
            }
        */
            /*------------------------------------------------------------
            Description:   To verify if logged user is Date checker and run scripts to schedule jobs
            ------------------------------------------------------------*/
            /*public static void dateCheckerScheduleJobs()
            {
                
                    ServiceContractDateChecker p = new ServiceContractDateChecker();
                    String sch1 = '0 0 * * * ?';
                    System.schedule('ServiceContractDateChecker - 0th min', sch1, p);
                    String sch2 = '0 15 * * * ?';
                    System.schedule('ServiceContractDateChecker - 15th min', sch2, p);
                    String sch3 = '0 30 * * * ?';
                    System.schedule('ServiceContractDateChecker - 30th min', sch3, p);
                    String sch4 = '0 45 * * * ?';
                    System.schedule('ServiceContractDateChecker - 45th min', sch4, p);
        
                    ContractDateChecker p1 = new ContractDateChecker();
                    System.schedule('ContractDateChecker - 0th min', sch1, p1);
                    System.schedule('ContractDateChecker - 15th min', sch2, p1);
                    System.schedule('ContractDateChecker - 30th min', sch3, p1);
                    System.schedule('ContractDateChecker - 45th min', sch4, p1);
            }     */           
            
            /*------------------------------------------------------------
            Description:   To verify if logged user is salesFadmin and run scripts to schedule jobs
            ------------------------------------------------------------*/
            /*public static void salesFAdminScheduleJobs()
            {
                    AccountInactiveReassign sc = new AccountInactiveReassign();
                    string cronExp = '0 10 00 * * ? *';
                    string JobId = system.schedule('AccountReassignScheduleJob', cronExp, sc);
            }*/
 
}