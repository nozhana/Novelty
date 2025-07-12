//
//  Story.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import Foundation
import SwiftData

@Model
final class Story {
    @Attribute(.unique)
    var id = UUID()
    var title: String?
    var tagline: String?
    var author: String?
    var created = Date.now
    var updated = Date.now
    
    @Relationship(deleteRule: .nullify, inverse: \StoryNode.story)
    var nodes: [StoryNode]
    
    var rootNode: StoryNode
    var currentNode: StoryNode?
    
    var folder: StoryFolder?
    
    init(id: UUID = UUID(), title: String? = nil, tagline: String? = nil, author: String? = nil, rootNode: StoryNode, currentNode: StoryNode? = nil, nodes: [StoryNode] = []) {
        self.id = id
        self.title = title
        self.tagline = tagline
        self.author = author
        self.rootNode = rootNode
        self.currentNode = currentNode
        self.nodes = nodes
    }
}

extension Story {
    convenience init(id: UUID = UUID(), title: String? = nil, tagline: String? = nil, author: String? = nil, currentNode: StoryNode? = nil, storyTree: @escaping () -> Tree<StoryNode>) {
        let tree = storyTree()
        let dfs = DFS(tree: tree)
        var nodes = [StoryNode]()
        for treeNode in dfs {
            treeNode.value.children = treeNode.children.map(\.value)
            nodes.append(treeNode.value)
        }
        self.init(id: id, title: title, tagline: tagline, author: author, rootNode: tree.value, currentNode: currentNode, nodes: nodes)
    }
}

#if DEBUG
extension Story {
    static let mockStory = {
        let story = Story(title: "Mock Story", tagline: "Mock Tagline", author: "John Doe", rootNode: .mockRoot, nodes: StoryNode.allMockNodes)
        return story
    }()
}
#endif

extension Story {
    static let permissionToSwap = Story(title: "Permission to Swap", tagline: "Evan has the power to swap anything with another person, but there's a catch. GPs given!", author: "Blarg Blargington") {
        Tree(StoryNode(title: "What a Strange Dream...",
                   content: """
It was a Friday morning in May and Evan did not want to get up for school. There was still a month of school left and he was ready for the summer. Evan groggily crawled out of bed and made his way to the bathroom. His head was spinning and he felt way more tired than he usually did in the morning. As he exited his room he crossed paths with his older sister Stephanie who, being a college freshmen, was already home for the summer.

"Good morning Evan," she said cheerily before heading downstairs. Evan mumbled some sort of response before going into the bathroom. Evan thought Stephanie was crazy. She was home now and could sleep as late as she wanted and she chose to get up at 7 in the morning. Evan wished he could still be sleeping right now.

What the hell is going on? he thought as he stared into the mirror. Why is my head pounding like this?

That's when he suddenly remembered the dream he had last night, the voice in his head. It had told him that he now had the power to swap anything with another person as long as he had their permission. It sounded absurd, but maybe, just maybe, this pounding in his head was due to the fact that he had been imbued with this power.

He was dying to know, so he forced himself to get ready as fast as possible so he could see if it was true. Once he was dressed, Evan headed downstairs and took stock of what he had to work with. His father Jack had already left for work, but the rest of his family was in the kitchen. There was Stephanie of course, and his younger tomboy of a sister Alex and his mother Miranda, who was a fourth grade teacher. Evan thought about what he would do before deciding to...
""")) {
            Tree(StoryNode(title: "Swap with Stephanie", linkTitle: "Try swapping something with Stephanie.", content: """
After eating breakfast, Evan waited for his mother and Alex to leave the room and then approached Stephanie about his new power.

"Hey Stephanie," he said. "I gained this power that lets me swap anything with another person."

"Are you feeling alright?" his sister asked with a laugh.

"I'm being serious. I had this dream that told me I have this power and I just feel like it's true."

"Just because you had a dream doesn't make it true," said Stephanie.

"Can we at least give it a try?" Evan asked.

"I guess it can't hurt," Stephanie agreed.

"Okay what do you want to try swapping?" Evan asked his sister.

"Hmm..." said Stephanie. "How about we try swapping..."
""")) {
                Tree(StoryNode(title: "Swapping schools", linkTitle: "...school.", content: "You and Stephanie swapped schools.\nYour life is way better now."))
                Tree(StoryNode(title: "Swapping chests", linkTitle: "...chests.", content: "You and Stephanie swapped chests.\nYou love your new bosom."))
                Tree(StoryNode(title: "Swapping skills", linkTitle: "...skills.", content: "You and Stephanie swapped skills.\nYou feel mildly uninteresting."))
            }
            
            Tree(StoryNode(title: "School", linkTitle: "Not try anything and go to school", content: """
If he was going to test out this power, Evan thought it would be best to test it out at school with one of his friends. They would be the most likely to believe him and the most trustworthy people to test it with.

Once he was all ready, Evan got into the car with his mother and sister and then he was off to school. Upon arrival, he headed off to his first class. Which class was it?
""")) {
                Tree(StoryNode(title: "Math with Amy", linkTitle: "Math (with his girlfriend Amy)", content: """
Evan smiled at his girlfriend as they entered class. He figured she would be the best person to try the powers on. The weren't allowed to talk in class so he couldn't speak to her. This allowed him to test another part of his power, he grabbed out a piece of paper and passed it to her.

It read: "If you could swap any body part with me what would it be?"

Amy looked at the note confused for a little bit, wondering what game Evan was playing. Though she thought it might be fun so she replied...
"""))
            }
        }
    }
}
