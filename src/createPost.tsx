import { Devvit } from '@devvit/public-api';

// Configure Devvit's plugins
Devvit.configure({
  redditAPI: true,
});

Devvit.addMenuItem({
  label: 'Create New Zero Block Game',
  location: 'subreddit',
  onPress: async (_event, context) => {
    const { reddit, ui } = context;
    const subreddit = await reddit.getCurrentSubreddit();
    const post = await reddit.submitPost({
      title: 'Zero Block',
      subredditName: subreddit.name,
      // The preview appears while the post loads
      preview: (
        <vstack height="100%" width="100%" alignment="middle center">
          <text size="large">Loading ...</text>
        </vstack>
      ),
    });
    ui.showToast({ text: 'Zero Block game created!' });
    ui.navigateTo(post);
  },
});
