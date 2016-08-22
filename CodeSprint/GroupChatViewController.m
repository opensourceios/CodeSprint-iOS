//
//  GroupChatViewController.m
//  CodeSprint
//
//  Created by Vincent Chau on 8/18/16.
//  Copyright © 2016 Vincent Chau. All rights reserved.
//

#import "GroupChatViewController.h"
#import "JSQMessages.h"
#import "FirebaseManager.h"
#import "Constants.h"
#include "Chatroom.h"
#include "ChatroomMessage.h"

@interface GroupChatViewController () <JSQMessagesCollectionViewDataSource>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@end

@implementation GroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self setupUser];
    [FirebaseManager observeChatroomFor:_currentTeam withCompletion:^(Chatroom *updatedChat) {
        NSLog(@"did return");
    }];
    self.title = @"Messages";
    self.messages = [[NSMutableArray alloc] init]; 
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    JSQMessage *firstMsg = [[JSQMessage alloc] initWithSenderId:@"asdfadsf" senderDisplayName:@"vincent" date:[NSDate date] text:@"testing 1234"];
    JSQMessage *firstMsg2 = [[JSQMessage alloc] initWithSenderId:@"asdfadsf" senderDisplayName:@"vincent" date:[NSDate date] text:@"testing 1234"];
    [self.messages addObject:firstMsg];
    [self.messages addObject:firstMsg2];
    [self finishReceivingMessage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Setup
-(void)setupUser{
    self.senderId = [FirebaseManager sharedInstance].currentUser.uid;
    self.senderDisplayName = [FirebaseManager sharedInstance].currentUser.displayName;
}
-(void)setupViews{
    self.navigationItem.title = @"Goals for this Sprint";
    self.navigationItem.hidesBackButton = YES;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
}
-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - JSQMessagesViewController Delegate
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.messages objectAtIndex:indexPath.item];
}
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *currentMsg = self.messages[indexPath.item];
    if ([currentMsg.senderId isEqualToString:self.senderId]) {
        return _outgoingBubbleImageData;
    }else{
        return _incomingBubbleImageData;
    }
}
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date{
    NSLog(@"DID PRESS SEND");
    ChatroomMessage *msg = [[ChatroomMessage alloc] initWithMessage:senderDisplayName withSenderID:senderId andText:text];
    [FirebaseManager sendMessageForChatroom:self.currentTeam withMessage:msg withCompletion:^(BOOL completed) {
        NSLog(@"DID FINISH SENDING MSG");
    }];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.messages count];
}

@end